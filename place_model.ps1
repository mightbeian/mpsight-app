# Place Model Script
# This script helps you place your trained model into the app

$ErrorActionPreference = "Stop"

Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 69) -ForegroundColor Cyan
Write-Host " MPSight Model Integration Helper" -ForegroundColor Cyan
Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 69) -ForegroundColor Cyan
Write-Host ""

# Check if assets/models directory exists
$assetsDir = "assets\models"
if (-not (Test-Path $assetsDir)) {
    Write-Host "[ERROR] Assets directory not found: $assetsDir" -ForegroundColor Red
    exit 1
}

# Check current model status
$modelPath = "$assetsDir\mpox_classifier.tflite"
if (Test-Path $modelPath) {
    $fileInfo = Get-Item $modelPath
    $fileSize = $fileInfo.Length
    
    Write-Host "[CURRENT MODEL STATUS]" -ForegroundColor Yellow
    Write-Host "  Location: $modelPath" -ForegroundColor Gray
    Write-Host "  Size: $fileSize bytes" -ForegroundColor Gray
    Write-Host "  Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Gray
    Write-Host ""
    
    if ($fileSize -lt 1000) {
        Write-Host "  Status: " -NoNewline
        Write-Host "PLACEHOLDER" -ForegroundColor Red
        Write-Host "  (File is too small to be a real model)" -ForegroundColor Gray
    } elseif ($fileSize -lt 1MB) {
        Write-Host "  Status: " -NoNewline
        Write-Host "SUSPICIOUS" -ForegroundColor Yellow
        Write-Host "  (File size seems small for a YOLOv8 model)" -ForegroundColor Gray
    } else {
        Write-Host "  Status: " -NoNewline
        Write-Host "READY" -ForegroundColor Green
        Write-Host "  (Model appears to be integrated)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Ask user for model file path
Write-Host "[INTEGRATION OPTIONS]" -ForegroundColor Yellow
Write-Host "  1. Copy a .tflite file from another location" -ForegroundColor Gray
Write-Host "  2. Use conversion script (if you have .pt file)" -ForegroundColor Gray
Write-Host "  3. Show integration status only" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Select option (1-3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "[COPY MODEL FILE]" -ForegroundColor Yellow
        $sourcePath = Read-Host "Enter path to your .tflite file"
        
        if (-not (Test-Path $sourcePath)) {
            Write-Host "[ERROR] File not found: $sourcePath" -ForegroundColor Red
            exit 1
        }
        
        $sourceInfo = Get-Item $sourcePath
        Write-Host ""
        Write-Host "Source file:" -ForegroundColor Gray
        Write-Host "  Path: $sourcePath" -ForegroundColor Gray
        Write-Host "  Size: $($sourceInfo.Length) bytes ($([math]::Round($sourceInfo.Length/1MB, 2)) MB)" -ForegroundColor Gray
        Write-Host ""
        
        if ($sourceInfo.Length -lt 100000) {
            $continue = Read-Host "Warning: File seems small. Continue? (y/n)"
            if ($continue -ne "y") {
                Write-Host "Aborted." -ForegroundColor Yellow
                exit 0
            }
        }
        
        # Backup existing model
        if ((Test-Path $modelPath) -and ((Get-Item $modelPath).Length -gt 1000)) {
            $backupPath = "$assetsDir\mpox_classifier_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').tflite"
            Write-Host "Backing up existing model to:" -ForegroundColor Yellow
            Write-Host "  $backupPath" -ForegroundColor Gray
            Copy-Item $modelPath $backupPath
        }
        
        # Copy new model
        Write-Host ""
        Write-Host "Copying model..." -ForegroundColor Yellow
        Copy-Item $sourcePath $modelPath -Force
        
        Write-Host "[SUCCESS] Model integrated!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  1. Run: flutter clean" -ForegroundColor Gray
        Write-Host "  2. Run: flutter pub get" -ForegroundColor Gray
        Write-Host "  3. Run: flutter run" -ForegroundColor Gray
        Write-Host "  4. Check console for: " -NoNewline -ForegroundColor Gray
        Write-Host "✅ Model loaded successfully" -ForegroundColor Green
    }
    
    "2" {
        Write-Host ""
        Write-Host "[CONVERSION SCRIPT]" -ForegroundColor Yellow
        
        if (-not (Test-Path "convert_to_tflite.py")) {
            Write-Host "[ERROR] Conversion script not found: convert_to_tflite.py" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "The conversion script will:" -ForegroundColor Gray
        Write-Host "  1. Install required Python packages" -ForegroundColor Gray
        Write-Host "  2. Convert your PyTorch model to TFLite" -ForegroundColor Gray
        Write-Host "  3. Copy it to assets/models/" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Before running, edit convert_to_tflite.py line 28 with your model path." -ForegroundColor Yellow
        Write-Host ""
        
        $continue = Read-Host "Run conversion script now? (y/n)"
        if ($continue -eq "y") {
            python convert_to_tflite.py
        } else {
            Write-Host "Aborted. Edit convert_to_tflite.py and run: python convert_to_tflite.py" -ForegroundColor Yellow
        }
    }
    
    "3" {
        Write-Host ""
        Write-Host "[INTEGRATION STATUS]" -ForegroundColor Yellow
        
        # Check Flutter dependencies
        Write-Host ""
        Write-Host "Checking Flutter setup..." -ForegroundColor Gray
        if (Test-Path "pubspec.yaml") {
            $pubspec = Get-Content "pubspec.yaml" -Raw
            if ($pubspec -match "tflite_flutter") {
                Write-Host "  ✓ tflite_flutter dependency found" -ForegroundColor Green
            } else {
                Write-Host "  ✗ tflite_flutter dependency missing" -ForegroundColor Red
            }
            
            if ($pubspec -match "assets/models/") {
                Write-Host "  ✓ Model assets configured" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Model assets not configured" -ForegroundColor Red
            }
        }
        
        # Check provider
        Write-Host ""
        Write-Host "Checking detection provider..." -ForegroundColor Gray
        if (Test-Path "lib\providers\detection_provider.dart") {
            $provider = Get-Content "lib\providers\detection_provider.dart" -Raw
            if ($provider -match "mpox_classifier\.tflite") {
                Write-Host "  ✓ Model path configured correctly" -ForegroundColor Green
            } else {
                Write-Host "  ✗ Model path not found in provider" -ForegroundColor Red
            }
            
            if ($provider -match "Chickenpox.*Cowpox.*Healthy.*HFMD.*Measles.*Monkeypox") {
                Write-Host "  ✓ MSLD v2.0 classes configured" -ForegroundColor Green
            } else {
                Write-Host "  ? Class labels may need verification" -ForegroundColor Yellow
            }
        }
        
        Write-Host ""
        Write-Host "Everything looks configured. " -NoNewline -ForegroundColor Green
        Write-Host "Place your model and run the app!" -ForegroundColor Gray
    }
    
    default {
        Write-Host "[ERROR] Invalid option" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 69) -ForegroundColor Cyan
