from pathlib import Path
import os, json, openai, subprocess

BASE_DIR   = Path(__file__).parent
ROOT_DIR   = BASE_DIR.parent

JSON_FILE  = BASE_DIR / "spells.json"
SOUNDS_DIR = ROOT_DIR / "Sounds"
TMP_DIR    = ROOT_DIR / "Temp"

os.makedirs(SOUNDS_DIR, exist_ok=True)
os.makedirs(TMP_DIR,    exist_ok=True)

openai.api_key = os.getenv("OPENAI_API_KEY")
if openai.api_key is None:
    raise ValueError("Please set the OPENAI_API_KEY environment variable.")

MODEL = "tts-1-hd"
VOICE = "nova"

def generate_voice(text, wav_path):
    print(f"Requesting audio for: {text}")
    try:
        with openai.audio.speech.with_streaming_response.create(
            model=MODEL, voice=VOICE, input=text
        ) as resp:
            resp.stream_to_file(wav_path)
    except Exception as e:
        raise RuntimeError(f"TTS error: {e}")
    print(f"Saved WAV: {wav_path}")

def convert_wav_to_ogg(wav_path, ogg_path):
    try:
        subprocess.run(
            ["ffmpeg","-y","-i",str(wav_path),"-af","volume=2.0",
             "-c:a","libvorbis","-qscale:a","5", str(ogg_path)],
            check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"ffmpeg error: {e.stderr.decode()}")
    print(f"Converted to OGG: {ogg_path}")

def main():
    data = json.loads(JSON_FILE.read_text(encoding="utf-8-sig"))

    count = 0
    for _, zones in data.items():
        for _, bosses in zones.items():
            for _, spells in bosses.items():
                for entry in spells:
                    sid  = entry.get("id")
                    txt  = entry.get("name")
                    if not sid or not txt: continue

                    wav = TMP_DIR  / f"{sid}.wav"
                    ogg = SOUNDS_DIR / f"{sid}.ogg"

                    if ogg.exists():
                        print(f"Skipping {ogg.name}")
                        continue

                    try:
                        generate_voice(txt, wav)
                        convert_wav_to_ogg(wav, ogg)
                        count += 1
                    finally:
                        if wav.exists(): wav.unlink()

    print(f"Done: {count} files generated.")

if __name__=="__main__":
    main()
