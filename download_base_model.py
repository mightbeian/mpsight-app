#!/usr/bin/env python3
"""
Download YOLOv8 base classification model from Ultralytics
This can be used as a starting point for fine-tuning on MSLD v2.0 dataset
"""
import os
import sys
import subprocess

print("="*70)
print("YOLOv8 Base Model Downloader")
print("="*70)

# Install ultralytics if needed
print("\n[1/3] Checking dependencies...")
try:
    from ultralytics import YOLO
    print("  ✓ Ultralytics already installed")
except ImportError:
    print("  Installing ultralytics...")
    subprocess.run([sys.executable, "-m", "pip", "install", "ultralytics"], check=True)
    from ultralytics import YOLO
    print("  ✓ Ultralytics installed")

# Download base model
print("\n[2/3] Downloading YOLOv8n-cls base model...")
print("  This is a pre-trained ImageNet model (1000 classes)")
print("  You'll need to fine-tune it on MSLD v2.0 dataset")

try:
    model = YOLO('yolov8n-cls.pt')
    print(f"  ✓ Model downloaded successfully")
    print(f"  Location: {os.path.abspath('yolov8n-cls.pt')}")
except Exception as e:
    print(f"  ✗ Download failed: {e}")
    sys.exit(1)

# Provide next steps
print("\n[3/3] Next Steps:")
print("="*70)
print("\nTo fine-tune this model on MSLD v2.0 dataset:")
print("\n1. Download MSLD v2.0 dataset from:")
print("   • Kaggle: https://www.kaggle.com/datasets/dipuiucse/monkeypoxskinimagedataset")
print("   • Or search: 'MSLD v2.0 Monkeypox dataset'")
print("\n2. Organize dataset in this structure:")
print("   data/")
print("     train/")
print("       Monkeypox/")
print("       Chickenpox/")
print("       Measles/")
print("       Cowpox/")
print("       HFMD/")
print("       Healthy/")
print("     val/")
print("       (same structure)")
print("\n3. Fine-tune the model:")
print("   ```python")
print("   from ultralytics import YOLO")
print("   model = YOLO('yolov8n-cls.pt')")
print("   results = model.train(")
print("       data='path/to/data',")
print("       epochs=100,")
print("       imgsz=640,")
print("       batch=16")
print("   )")
print("   ```")
print("\n4. Export to TFLite using convert_to_tflite.py")
print("="*70)
print("\nAlternatively, if you have a trained .pt model:")
print("  • Place it in Downloads folder")
print("  • Update path in convert_to_tflite.py (line 28)")
print("  • Run: python convert_to_tflite.py")
print("="*70)
