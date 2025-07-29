

import logging
from fastapi import FastAPI, Request, HTTPException, Response, Body
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import os
from csv_helper import read_csv, write_csv, append_csv, csv_to_dict
import datetime

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()
current_dir= os.path.dirname(os.path.abspath(__file__))
print(f"Current directory: {current_dir}")

CSV_FILES = {
    "user_entry": {
        "path": os.path.abspath(os.path.join(current_dir, "logs", "user_entry.csv")),
        "fields": ["roll_number", "name", "date", "time"],
        "permission": "crud"
    }
}

print(f"CSV file path: {CSV_FILES['user_entry']}")

# df=read_csv(CSV_FILES["user_entry"]["path"])
# if not df:
#     logger.info("CSV file is empty or does not exist.")
# else:
#     logger.info(f"CSV file loaded successfully with {len(df)} records.")
# input()

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

from fastapi import HTTPException

def check_permission(file_key, action):
    perms = CSV_FILES[file_key]["permission"]
    if action == "create" and "c" not in perms:
        raise HTTPException(status_code=403, detail="Create not allowed")
    if action == "read" and "r" not in perms:
        raise HTTPException(status_code=403, detail="Read not allowed")
    if action == "update" and "u" not in perms:
        raise HTTPException(status_code=403, detail="Update not allowed")
    if action == "delete" and "d" not in perms:
        raise HTTPException(status_code=403, detail="Delete not allowed")

USER_ENTRY_FIELDS = ["roll_number", "name", "date", "time", "last_login"]

@app.get("/user_entry")
def get_user_entries():
    ensure_user_entry_csv_exists()
    data = read_csv(get_user_entry_path())
    if not data:
        return {"status": "no records found", "data": []}
    return {"status": "success", "data": data}

@app.get("/user_entry/should_calibrate")
def should_calibrate(roll_number: str):
    """
    Returns a flag should_calibrate: bool indicating if the user should calibrate.
    If the user is new or last login was more than 24 hours ago, should_calibrate is True.
    Otherwise, False.
    """
    ensure_user_entry_csv_exists()
    data = read_csv(get_user_entry_path())
    if not data:
        # No users, so new user scenario
        return {"should_calibrate": True}
    now = datetime.datetime.now()
    for row in data:
        if row["roll_number"] == roll_number:
            last_login_str = row.get("last_login")
            if not last_login_str:
                return {"should_calibrate": True}
            try:
                last_login = datetime.datetime.fromisoformat(last_login_str)
            except Exception:
                return {"should_calibrate": True}
            delta = now - last_login
            if delta.total_seconds() > 24 * 3600:
                return {"should_calibrate": True}
            else:
                return {"should_calibrate": False}
    # User not found, new user
    return {"should_calibrate": True}

@app.post("/user_entry")
def add_user_entry(entry: dict = Body(...)):
    ensure_user_entry_csv_exists()
    for field in ["roll_number", "name"]:
        if field not in entry:
            raise HTTPException(status_code=400, detail=f"Missing field: {field}")
    # Check for duplicate roll_number
    existing_entries = read_csv(get_user_entry_path())
    for row in existing_entries:
        if row["roll_number"] == entry["roll_number"]:
            # Update last_login for returning user
            row["last_login"] = datetime.datetime.now().isoformat()
            write_csv(get_user_entry_path(), existing_entries, USER_ENTRY_FIELDS)
            # Determine should_calibrate flag
            should_calibrate_flag = True
            last_login_str = row.get("last_login")
            if last_login_str:
                try:
                    last_login = datetime.datetime.fromisoformat(last_login_str)
                    delta = datetime.datetime.now() - last_login
                    if delta.total_seconds() <= 24 * 3600:
                        should_calibrate_flag = False
                except Exception:
                    should_calibrate_flag = True
            else:
                should_calibrate_flag = True
            return {"status": "welcome_back", "should_calibrate": should_calibrate_flag}
        # If somehow no return happened above, fall through to return below
    # New user: add entry
    now = datetime.datetime.now().isoformat()
    new_entry = {
        "roll_number": entry["roll_number"],
        "name": entry["name"],
        "date": entry.get("date", now[:10]),
        "time": entry.get("time", now[11:19]),
        "last_login": now
    }
    append_csv(get_user_entry_path(), [new_entry], USER_ENTRY_FIELDS)
    # New user should calibrate
    return {"status": "entry added", "should_calibrate": True}
    # New user: add entry
    now = datetime.datetime.now().isoformat()
    new_entry = {
        "roll_number": entry["roll_number"],
        "name": entry["name"],
        "date": entry.get("date", now[:10]),
        "time": entry.get("time", now[11:19]),
        "last_login": now
    }
    append_csv(get_user_entry_path(), [new_entry], USER_ENTRY_FIELDS)
    # New user should calibrate
    return {"status": "entry added", "should_calibrate": True}

@app.put("/user_entry")
def update_user_entry(entry: dict = Body(...)):
    """
    Update a user entry by roll_number. Expects a JSON body with roll_number and any fields to update.
    """
    ensure_user_entry_csv_exists()
    if "roll_number" not in entry:
        raise HTTPException(status_code=400, detail="Missing field: roll_number")

    entries = read_csv(get_user_entry_path())
    updated = False
    for row in entries:
        if row["roll_number"] == entry["roll_number"]:
            for field in USER_ENTRY_FIELDS:
                if field in entry and field != "roll_number":
                    row[field] = entry[field]
            updated = True
            break

    if not updated:
        raise HTTPException(status_code=404, detail="Entry with given roll_number not found")

    write_csv(get_user_entry_path(), entries, USER_ENTRY_FIELDS)
    return {"status": "entry updated"}

@app.delete("/user_entry")
def delete_user_entries():
    path = get_user_entry_path()
    if os.path.exists(path):
        os.remove(path)
    return {"status": "user_entry CSV deleted"}

def get_user_entry_path():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    logs_dir = os.path.join(current_dir, "logs")
    os.makedirs(logs_dir, exist_ok=True)
    return os.path.join(logs_dir, "user_entry.csv")

def ensure_user_entry_csv_exists():
    path = get_user_entry_path()
    if not os.path.exists(path):
        from csv_helper import write_csv
        write_csv(path, [], ["roll_number", "name", "date", "time", "last_login"])

# Shaft measurement fields and CSV path
SHAFT_MEASUREMENT_FIELDS = ["product_id", "roll_number", "shaft_height", "shaft_radius"]
HOUSING_MEASUREMENT_FIELDS = ["product_id", "roll_number", "housing_height", "housing_radius", "housing_depth"]


def get_measured_shafts_path():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    logs_dir = os.path.join(current_dir, "logs")
    os.makedirs(logs_dir, exist_ok=True)
    return os.path.join(logs_dir, "measured_shafts.csv")

def get_measured_housings_path():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    logs_dir = os.path.join(current_dir, "logs")
    os.makedirs(logs_dir, exist_ok=True)
    return os.path.join(logs_dir, "measured_housings.csv")


def clear_user_entry_csv():
    path = get_user_entry_path()
    if os.path.exists(path):
        os.remove(path)
    return {"status": "user_entry CSV deleted"}



def clear_measured_shafts_csv():
    path = get_measured_shafts_path()
    if os.path.exists(path):
        os.remove(path)
    return {"status": "measured_shafts CSV deleted"}

def clear_measured_housings_csv():
    path = get_measured_housings_path()
    if os.path.exists(path):
        os.remove(path)
    return {"status": "measured_housings CSV deleted"}



def ensure_measured_shafts_csv_exists():
    path = get_measured_shafts_path()
    if not os.path.exists(path):
        from csv_helper import write_csv
        write_csv(path, [], SHAFT_MEASUREMENT_FIELDS)

def ensure_measured_housings_csv_exists():
    path = get_measured_housings_path()
    if not os.path.exists(path):
        from csv_helper import write_csv
        write_csv(path, [], HOUSING_MEASUREMENT_FIELDS)


# Shaft measurement endpoint
@app.post("/shaft_measurement")
def add_shaft_measurement(entry: dict = Body(...)):
    """
    Add a new shaft measurement. Expects a JSON body with product_id, roll_number, shaft_height, shaft_radius.
    """
    ensure_measured_shafts_csv_exists()
    for field in SHAFT_MEASUREMENT_FIELDS:
        if field not in entry:
            raise HTTPException(status_code=400, detail=f"Missing field: {field}")
    from csv_helper import append_csv
    append_csv(get_measured_shafts_path(), [entry], SHAFT_MEASUREMENT_FIELDS)
    return {"status": "shaft measurement added"}

# Housing measurement endpoint
@app.post("/housing_measurement")
def add_housing_measurement(entry: dict = Body(...)):
    """
    Add a new housing measurement. Expects a JSON body with product_id, roll_number, housing_height, housing_radius, housing_depth.
    """
    ensure_measured_housings_csv_exists()
    for field in HOUSING_MEASUREMENT_FIELDS:
        if field not in entry:
            raise HTTPException(status_code=400, detail=f"Missing field: {field}")
    from csv_helper import append_csv
    append_csv(get_measured_housings_path(), [entry], HOUSING_MEASUREMENT_FIELDS)
    return {"status": "housing measurement added"}

@app.get("/shaft_measurement")
def get_shaft_measurements():
    ensure_measured_shafts_csv_exists()
    data = read_csv(get_measured_shafts_path())
    if not data:
        return {"status": "no records found", "data": []}
    return {"status": "success", "data": data}

@app.put("/shaft_measurement")
def update_shaft_measurement(entry: dict = Body(...)):
    """
    Update a shaft measurement by part_number. Expects a JSON body with part_number and any fields to update.
    """
    ensure_measured_shafts_csv_exists()
    if "part_number" not in entry:
        raise HTTPException(status_code=400, detail="Missing field: part_number")

    entries = read_csv(get_measured_shafts_path())
    updated = False
    for row in entries:
        if row["part_number"] == entry["part_number"]:
            for field in SHAFT_MEASUREMENT_FIELDS:
                if field in entry and field != "part_number":
                    row[field] = entry[field]
            updated = True
            break

    if not updated:
        raise HTTPException(status_code=404, detail="Entry with given part_number not found")

    write_csv(get_measured_shafts_path(), entries, SHAFT_MEASUREMENT_FIELDS)
    return {"status": "shaft measurement updated"}

@app.delete("/shaft_measurement")
def delete_shaft_measurements():
    path = get_measured_shafts_path()
    if os.path.exists(path):
        os.remove(path)
    return {"status": "measured_shafts CSV deleted"}

@app.delete("/clear_measured_shafts")
def clear_measured_shafts_endpoint():
    return clear_measured_shafts_csv()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)