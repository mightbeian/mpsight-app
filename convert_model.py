#!/usr/bin/env python3
"""
Convert YOLOv8 PyTorch model to TensorFlow Lite format
"""
import os
import sys

try:
    from ultralytics import YOLO
except ImportError:
    print("Installing ultralytics...")
    os.system("pip install ultralytics")
    from ultralytics import YOLO

# Path to the trained model
model_path = r"C:\Users\Lenovo\Downloads\First Run\msld_full_final_TUNED\content\runs\classify\msld_v2_yolov8n_cls3\weights\best.pt"

print(f"Loading model from: {model_path}")
model = YOLO(model_path)

# First export to ONNX (faster and more reliable)
print("Exporting to ONNX format...")
try:
    onnx_path = model.export(format='onnx', imgsz=640, simplify=True)
    print(f"ONNX export successful: {onnx_path}")
except Exception as e:
    print(f"ONNX export failed: {e}")

# Try TFLite export
print("\nExporting to TensorFlow Lite format...")
try:
    output_path = model.export(format='tflite', imgsz=640, int8=False)
    print(f"TFLite export successful: {output_path}")
    
    # Copy to assets folder
    import shutil
    assets_dir = r"c:\Users\Lenovo\Desktop\MPSIGHT\mpsight-app\assets\models"
    os.makedirs(assets_dir, exist_ok=True)
    target_path = os.path.join(assets_dir, "mpox_classifier.tflite")
    shutil.copy(output_path, target_path)
    print(f"Copied to: {target_path}")
except Exception as e:
    print(f"TFLite export failed: {e}")
    print("\nPlease install TensorFlow manually: pip install tensorflow")
