# 參數設定
CRF_VALUES := 18 20 23 25 28

all: $(addprefix vmaf_crf, $(CRF_VALUES))

# 每個 CRF 的目標
vmaf_crf%:
	./evaluate_crf.sh $*

clean:
	rm -f foreman_crf*.mp4 foreman_crf*_decoded.yuv output_crf*.xml

.PHONY: all clean
