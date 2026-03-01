# 漫剧项目上下文（迁移用副本）

本目录为漫剧项目三类文档的副本，供迁移到新项目时使用。


| 类型         | 源位置              | 本目录            |
| ---------- | ---------------- | -------------- |
| **Rules**  | `.cursor/rules/` | `rules/`       |
| **AGENTS** | `AGENTS.md`      | `AGENTS.md`    |
| **README** | `README.md`      | `README-项目.md` |


**迁移步骤**：

1. 将 `rules/*.mdc` 复制到目标项目的 `.cursor/rules/`
2. 将 `AGENTS.md` 复制到目标项目根目录
3. 将 `README-项目.md` 复制到目标项目根目录并重命名为 `README.md`
4. 按目标项目实际情况调整 globs 路径（如 `anime_ai`→新后端目录名）及文档内引用

