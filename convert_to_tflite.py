#!/usr/bin/env python3
"""
Convert YOLOv8 PyTorch model to TensorFlow Lite format
Run this with: python convert_to_tflite.py
"""
import os
import sys
import subprocess

print("="*70)
print("YOLOv8 to TFLite Converter")
print("="*70)

# Install required packages
print("\n[1/4] Installing dependencies...")
packages = ["ultralytics", "tensorflow>=2.13.0", "onnx", "onnxruntime"]
for package in packages:
    print(f"  Installing {package}...")
    subprocess.run([sys.executable, "-m", "pip", "install", "-q", package], check=False)

print("✓ Dependencies installed\n")

# Import after installation
from ultralytics import YOLO
import shutil

# Paths
model_path = r"C:\Users\Lenovo\Downloads\First Run\msld_full_final_TUNED\content\runs\classify\msld_v2_yolov8n_cls3\weights\best.pt"
assets_dir = r"c:\Users\Lenovo\Desktop\MPSIGHT\mpsight-app\assets\models"

print(f"[2/4] Loading model...")
print(f"  Source: {model_path}")
model = YOLO(model_path)

# Print model info
print(f"\n  Model Info:")
print(f"    Task: {model.task}")
print(f"    Classes: {list(model.names.values())}")

print(f"\n[3/4] Exporting to TensorFlow Lite...")
print("  This may take 2-5 minutes...\n")

try:
    # Export with explicit options
    export_path = model.export(
        format='tflite',
        imgsz=640,
        int8=False,
        half=False,
        dynamic=False,
        simplify=True
    )
    
    print(f"\n✓ Export successful!")
    print(f"  Output: {export_path}")
    
    # Copy to assets
    print(f"\n[4/4] Copying to app...")
    os.makedirs(assets_dir, exist_ok=True)
    target_path = os.path.join(assets_dir, "best_float32.tflite")
    shutil.copy(export_path, target_path)
    print(f"  ✓ Model: {target_path}")
    
    # Save class labels
    labels_path = os.path.join(assets_dir, "labels.txt")
    with open(labels_path, "w") as f:
        for name in model.names.values():
            f.write(f"{name}\n")
    print(f"  ✓ Labels: {labels_path}")
    
    # Get file size
    size_mb = os.path.getsize(target_path) / (1024 * 1024)
    print(f"\n  Model size: {size_mb:.2f} MB")
    
    print("\n" + "="*70)
    print("CONVERSION COMPLETE! ✓")
    print("="*70)
    print("\nYou can now rebuild the Flutter app with the new model.")
    
except Exception as e:
    print(f"\n✗ Export failed!")
    print(f"Error: {e}")
    print("\nTroubleshooting:")
    print("  1. Ensure TensorFlow is installed: pip install tensorflow")
    print("  2. Try updating ultralytics: pip install -U ultralytics")
    print("  3. Check Python version (3.8-3.11 recommended)")
    sys.exit(1)
