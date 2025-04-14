import os
import openai
import subprocess
from pathlib import Path

SRC_DIR = "src"        # Contains all spells
SOUNDS_DIR = "sounds"  # Output folder for the generated OGG files
TMP_DIR = "tmp_wav"    # Temporary folder for WAV files

# Create necessary directories if they don't exist
os.makedirs(SOUNDS_DIR, exist_ok=True)
os.makedirs(TMP_DIR, exist_ok=True)

openai.api_key = os.getenv("OPENAI_API_KEY")
if openai.api_key is None:
    raise ValueError("Please set OPENAI_API_KEY environment variable.")

# TTS settings: using tts-1-hd model with "Nova" voice
MODEL = "tts-1-hd"
VOICE = "nova"

def generate_voice(text, mp3_filepath):
    """
    Uses OpenAI TTS to generate an MP3 audio file from input text.
    """
    print(f"Requesting audio for: {text}")
    mp3_path = Path(mp3_filepath)
    try:
        with openai.audio.speech.with_streaming_response.create(
            model=MODEL,
            voice=VOICE,
            input=text
        ) as response:
            response.stream_to_file(mp3_path)
    except Exception as ex:
        raise RuntimeError(f"OpenAI TTS API error: {ex}")
    print(f"Saved temporary MP3: {mp3_path}")

def convert_wav_to_ogg(wav_filepath, ogg_filepath):
    """
    Uses ffmpeg to convert a WAV file into an OGG file.
    """
    try:
        subprocess.run(
            ["ffmpeg", "-y", "-i", wav_filepath, "-c:a", "libvorbis", "-qscale:a", "5", ogg_filepath],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"ffmpeg conversion error: {e.stderr.decode('utf-8')}")
    print(f"Converted {wav_filepath} to OGG: {ogg_filepath}")

def process_spell_file(filepath):
    """
    Reads a spell file (tab-separated) and generates an OGG file for each spell line.
    """
    print(f"Processing: {filepath}")
    with open(filepath, "r", encoding="utf-8") as file:
        for line in file:
            line = line.strip()
            # Skip empty lines or lines starting with '#' or ';' (comments)
            if not line or line.startswith("#") or line.startswith(";"):
                continue
            try:
                # Expecting two columns: SPELL_NAME and Text-to-speak.
                spell_name, spell_text = line.split("\t", 1)
                spell_name = spell_name.strip()
                spell_text = spell_text.strip()
            except ValueError:
                print("Skipping malformed line:", line)
                continue

            # Create filenames – we use the spell name in uppercase for consistency.
            wav_filename = f"{spell_name.upper()}.wav"
            ogg_filename = f"{spell_name.upper()}.ogg"
            wav_filepath = os.path.join(TMP_DIR, wav_filename)
            ogg_filepath = os.path.join(SOUNDS_DIR, ogg_filename)

            # Skip if the OGG file already exists
            if os.path.exists(ogg_filepath):
                print(f"File {ogg_filename} already exists, skipping.")
                continue

            print(f"Generating voice for '{spell_name}': \"{spell_text}\"")
            try:
                generate_voice(spell_text, wav_filepath)
                convert_wav_to_ogg(wav_filepath, ogg_filepath)
                print(f"Generated voice file: {ogg_filename}")
            except Exception as e:
                print(f"Error generating voice for {spell_name}: {e}")
            finally:
                if os.path.exists(wav_filepath):
                    os.remove(wav_filepath)

def main():
    """
    Process all spells-*.txt files in the src folder.
    """
    for filename in os.listdir(SRC_DIR):
        if filename.startswith("spells-") and filename.endswith(".txt"):
            filepath = os.path.join(SRC_DIR, filename)
            process_spell_file(filepath)
    print("Voice generation completed.")

if __name__ == "__main__":
    main()
