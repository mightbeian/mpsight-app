#!/usr/bin/env python3
"""Quick converter - assumes ultralytics is already installed"""
from ultralytics import YOLO
import shutil
import os

print("Converting model to TFLite...")

# Load model
model = YOLO(r"C:\Users\Lenovo\Downloads\First Run\msld_full_final_TUNED\content\runs\classify\msld_v2_yolov8n_cls3\weights\best.pt")
print(f"Model loaded: {list(model.names.values())}")

# Export to TFLite
print("Exporting... (this may take 2-5 minutes)")
export_path = model.export(format='tflite', imgsz=640, int8=False)
print(f"Exported to: {export_path}")

# Copy to assets
assets_dir = r"c:\Users\Lenovo\Desktop\MPSIGHT\mpsight-app\assets\models"
target_path = os.path.join(assets_dir, "best_fp32.tflite")
os.makedirs(assets_dir, exist_ok=True)
shutil.copy(export_path, target_path)

size_mb = os.path.getsize(target_path) / (1024 * 1024)
print(f"\n✓ Model copied to: {target_path}")
print(f"✓ Size: {size_mb:.2f} MB")
print("\nReady to use! Run 'flutter run' to test.")
