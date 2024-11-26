#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <CRF>"
    exit 1
fi

CRF=$1

# 原始參數設定
INPUT_Y4M="foreman_cif.y4m"
RAW_YUV="foreman_352x288_29.97_300.yuv"
WIDTH=352
HEIGHT=288
FPS=29.97
PIX_FMT="yuv420p"
BITDEPTH=8
MODEL="vmaf_v0.6.1"
FEATURES="psnr"
FRAMES=60
PRESET="medium"

# 輸出檔案
ENCODED_MP4="foreman_crf${CRF}.mp4"
DECODED_YUV="foreman_crf${CRF}_decoded.yuv"
VMAF_XML="output_crf${CRF}.xml"

# 檢查原始 YUV 是否存在
if [ ! -f "$RAW_YUV" ]; then
    echo "Raw YUV not found. Generating raw YUV..."
    ffmpeg -i $INPUT_Y4M -c:v rawvideo -pix_fmt $PIX_FMT $RAW_YUV
fi

# 編碼
echo "Encoding with CRF=$CRF..."
ffmpeg -f rawvideo -pixel_format $PIX_FMT -s ${WIDTH}x${HEIGHT} -r $FPS -i \
    $RAW_YUV -frames:v $FRAMES -c:v libx264 -crf $CRF -preset $PRESET $ENCODED_MP4

# 解碼
echo "Decoding CRF=$CRF..."
ffmpeg -i $ENCODED_MP4 -c:v rawvideo -pix_fmt $PIX_FMT $DECODED_YUV

# 計算 VMAF
echo "Calculating VMAF for CRF=$CRF..."
vmaf --reference $RAW_YUV \
    --distorted $DECODED_YUV \
    --width $WIDTH --height $HEIGHT --pixel_format 420 --bitdepth $BITDEPTH \
    --model version=$MODEL \
    --feature $FEATURES \
    --output $VMAF_XML

echo "CRF=$CRF evaluation completed. Results saved to $VMAF_XML."
