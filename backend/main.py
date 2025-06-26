import logging
from fastapi import FastAPI, Request, HTTPException, Response, Body
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import os
from csv_helper import read_csv, write_csv, append_csv, csv_to_dict

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()
current_dir= os.path.dirname(os.path.abspath(__file__))
print(f"Current directory: {current_dir}")

CSV_FILES = {
    "housing": os.path.abspath(os.path.join(current_dir, "logs", "housing.csv")),
}



# Allow CORS for local development (adjust origins as needed)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Get the current directory and construct paths
current_dir = os.path.dirname(os.path.abspath(__file__))
assets_dir = os.path.abspath(os.path.join(current_dir, "..", "assets"))

VIDEO_DIRS = {
    "housing": os.path.abspath(os.path.join(assets_dir, "housing")),
    "shaft": os.path.abspath(os.path.join(assets_dir, "shaft")),
}

# Log the paths for debugging
logger.info(f"Current directory: {current_dir}")
logger.info(f"Assets directory: {assets_dir}")
for category, path in VIDEO_DIRS.items():
    logger.info(f"Video directory for {category}: {path}")
    logger.info(f"Directory exists: {os.path.exists(path)}")

CHUNK_SIZE = 1024 * 1024  # 1MB

@app.get("/")
async def root():
    return {"message": "Video API Server is running"}

@app.get("/debug/paths")
async def debug_paths():
    return {
        "current_dir": current_dir,
        "assets_dir": assets_dir,
        "video_dirs": VIDEO_DIRS,
        "dirs_exist": {k: os.path.exists(v) for k, v in VIDEO_DIRS.items()}
    }

def get_video_path(category: str, filename: str) -> str:
    logger.info(f"Getting video path for category: {category}, filename: {filename}")
    if category not in VIDEO_DIRS:
        logger.error(f"Category '{category}' not found in VIDEO_DIRS: {list(VIDEO_DIRS.keys())}")
        raise HTTPException(status_code=404, detail="Category not found")
    path = os.path.join(VIDEO_DIRS[category], filename)
    logger.info(f"Full video path: {path}")
    if not os.path.isfile(path):
        logger.error(f"File not found: {path}")
        raise HTTPException(status_code=404, detail="File not found")
    return path

async def range_streamer(file_path: str, start: int, end: int):
    with open(file_path, "rb") as f:
        f.seek(start)
        remaining = end - start + 1
        while remaining > 0:
            chunk_size = min(CHUNK_SIZE, remaining)
            data = f.read(chunk_size)
            if not data:
                break
            yield data
            remaining -= len(data)

@app.get("/video/list/{category}")
async def list_videos(category: str):
    logger.info(f"Listing videos for category: {category}")
    if category not in VIDEO_DIRS:
        logger.error(f"Category '{category}' not found. Available categories: {list(VIDEO_DIRS.keys())}")
        raise HTTPException(status_code=404, detail="Category not found")
    
    dir_path = VIDEO_DIRS[category]
    logger.info(f"Listing files in directory: {dir_path}")
    
    if not os.path.exists(dir_path):
        logger.error(f"Directory does not exist: {dir_path}")
        raise HTTPException(status_code=404, detail="Directory not found")
    
    try:
        files = [f for f in os.listdir(dir_path) if os.path.isfile(os.path.join(dir_path, f))]
        logger.info(f"Found {len(files)} files: {files}")
        return JSONResponse(content=files)
    except Exception as e:
        logger.error(f"Error listing directory {dir_path}: {e}")
        raise HTTPException(status_code=500, detail="Error listing directory")

@app.get("/video/{category}/{filename}")
async def stream_video(request: Request, category: str, filename: str):
    file_path = get_video_path(category, filename)
    file_size = os.path.getsize(file_path)
    range_header = request.headers.get("range")
    if range_header:
        # Example: Range: bytes=0-1023
        try:
            range_value = range_header.strip().lower().split("bytes=")[1]
            start_str, end_str = range_value.split("-")
            start = int(start_str) if start_str else 0
            end = int(end_str) if end_str else file_size - 1
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid Range header")
        if start > end or end >= file_size:
            raise HTTPException(status_code=416, detail="Requested Range Not Satisfiable")
        headers = {
            "Content-Range": f"bytes {start}-{end}/{file_size}",
            "Accept-Ranges": "bytes",
            "Content-Length": str(end - start + 1),
            "Content-Type": "video/mp4",
        }
        return StreamingResponse(
            range_streamer(file_path, start, end),
            status_code=206,
            headers=headers,
        )
    else:
        headers = {
            "Content-Length": str(file_size),
            "Content-Type": "video/mp4",
            "Accept-Ranges": "bytes",
        }
        return StreamingResponse(
            range_streamer(file_path, 0, file_size - 1),
            headers=headers,
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)