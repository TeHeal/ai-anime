package mesh

import "go.uber.org/zap"

// ZapLogger 将 zap.Logger 适配为 mesh.Logger 接口
type ZapLogger struct {
	L *zap.Logger
}

// NewZapLogger 创建 zap 适配的 mesh Logger
func NewZapLogger(l *zap.Logger) *ZapLogger {
	return &ZapLogger{L: l}
}

// Info 记录信息日志
func (z *ZapLogger) Info(msg string, fields map[string]any) {
	zapFields := mapToZapFields(fields)
	z.L.Info(msg, zapFields...)
}

// Error 记录错误日志
func (z *ZapLogger) Error(msg string, fields map[string]any) {
	zapFields := mapToZapFields(fields)
	z.L.Error(msg, zapFields...)
}

func mapToZapFields(m map[string]any) []zap.Field {
	fields := make([]zap.Field, 0, len(m))
	for k, v := range m {
		fields = append(fields, zap.Any(k, v))
	}
	return fields
}
