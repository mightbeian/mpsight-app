#!/usr/bin/env python3
"""Simple model export - try ONNX format which is more compatible"""
from ultralytics import YOLO
import os

print("="*70)
print("Simple Model Export")
print("="*70)

model_path = r"C:\Users\Lenovo\Downloads\First Run\msld_full_final_TUNED\content\runs\classify\msld_v2_yolov8n_cls3\weights\best.pt"

print(f"\nLoading model from:")
print(f"  {model_path}")

try:
    model = YOLO(model_path)
    print(f"\n✓ Model loaded successfully!")
    print(f"  Classes: {list(model.names.values())}")
    print(f"  Number of classes: {len(model.names)}")
    
    # Try exporting to ONNX (more compatible than TFLite)
    print(f"\nExporting to ONNX format...")
    onnx_path = model.export(format='onnx', imgsz=640, simplify=True)
    print(f"\n✓ ONNX export successful!")
    print(f"  File: {onnx_path}")
    
    size_mb = os.path.getsize(onnx_path) / (1024 * 1024)
    print(f"  Size: {size_mb:.2f} MB")
    
    print("\n" + "="*70)
    print("Next steps:")
    print("  1. Install onnx2tf: pip install onnx2tf")
    print("  2. Convert: onnx2tf -i model.onnx -o tflite/")
    print("  OR use online converter:")
    print("  https://convertmodel.com/")
    print("="*70)
    
except Exception as e:
    print(f"\n✗ Error: {e}")
    print("\nIf this fails, you can:")
    print("  1. Use the model file directly (already 5.8MB)")
    print("  2. Or find a system with Python 3.10 for TFLite export")
