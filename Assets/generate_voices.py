import random
import os, json, sys, subprocess, argparse
import openai
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

PARALLELISM = 4
MODEL       = "tts-1-hd"
VOICE       = "sage"

USE_PHRASES = 1
PHRASE_PATTERNS = [
    ".. {name} .."
    ".. Incoming, {name} ..",
    ".. Warning, {name} ..",
    ".. {name} now ..",
    ".. Prepare yourself for {name} ..",
    ".. Get ready for {name} ..",
    ".. Danger, {name} ..",
    ".. Heads up {name} ..",
    ".. Alert, {name} ..",
    ".. Caution, {name} ..",
    ".. Here comes {name} ..",
    ".. Be ready for {name} ..",
]

BASE_DIR  = Path(__file__).resolve().parent
ROOT_DIR  = BASE_DIR.parent
JSON_FILE = BASE_DIR / "spells.json"
OUT_DIR   = ROOT_DIR / "Sounds" / VOICE.capitalize()
TMP_DIR   = ROOT_DIR / "Temp"

OUT_DIR.mkdir(parents=True, exist_ok=True)
TMP_DIR.mkdir(exist_ok=True)

openai.api_key = os.getenv("OPENAI_API_KEY") or ""
if not openai.api_key:
    sys.exit("OPENAI_API_KEY missing")

argp = argparse.ArgumentParser()
argp.add_argument("--test",    action="store_true")
args = argp.parse_args()

def log(msg):
    try:
        print(msg, flush=True)
    except UnicodeEncodeError:
        print(msg.encode("ascii", "replace").decode(), flush=True)

def generate_voice(text, wav_path):
    if USE_PHRASES:
        phrased = random.choice(PHRASE_PATTERNS).format(name=text.strip().lower())
    else:
        phrased = f"{text.strip()} .."
    log(f"TTS  -> {wav_path.name}   ({phrased})")
    with openai.audio.speech.with_streaming_response.create(
        model=MODEL, voice=VOICE, input=phrased
    ) as resp:
        resp.stream_to_file(str(wav_path))

def convert_wav_to_ogg(wav_path, ogg_path):
    cmd = ["ffmpeg", "-y", "-i", str(wav_path), "-af", "volume=1.75", "-c:a", "libvorbis", "-qscale:a", "5", str(ogg_path)]
    log(f"FFMPEG -> {ogg_path.name}")
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if res.returncode:
        raise RuntimeError(res.stderr.decode().strip())

def worker(entry):
    sid, text = entry.get("id"), entry.get("name")
    if not sid or not text:
        return None
    ogg = OUT_DIR / f"{sid}.ogg"
    if ogg.exists():
        log(f"skip {ogg.name}")
        return None
    wav = TMP_DIR / f"{sid}.wav"
    try:
        generate_voice(text, wav)
        convert_wav_to_ogg(wav, ogg)
        return ogg.name
    finally:
        wav.unlink(missing_ok=True)

def main():
    data = json.loads(JSON_FILE.read_text(encoding="utf-8-sig"))
    futures, produced = [], 0
    with ThreadPoolExecutor(max_workers=PARALLELISM) as pool:
        for _, zones in data.items():
            for zone_name, bosses in zones.items():
                for boss_name, spells in bosses.items():
                    if args.test and not (
                        zone_name == "Liberation of Undermine" and
                        boss_name == "Vexie and the Geargrinders"
                    ):
                        continue
                    for entry in spells:
                        futures.append(pool.submit(worker, entry))
        for fut in as_completed(futures):
            try:
                if fut.result():
                    produced += 1
            except Exception as e:
                print("error:", e, file=sys.stderr)
    print(f"{produced} new file(s) in {OUT_DIR.relative_to(ROOT_DIR)}")

if __name__ == "__main__":
    main()
