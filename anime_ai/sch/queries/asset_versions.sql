-- name: CreateAssetVersion :one
INSERT INTO asset_versions (asset_type, asset_id, project_id, version, snapshot_json, change_note, created_by)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- name: ListAssetVersions :many
SELECT * FROM asset_versions WHERE asset_type = $1 AND asset_id = $2
ORDER BY version DESC;

-- name: GetAssetVersion :one
SELECT * FROM asset_versions WHERE id = $1;

-- name: GetLatestAssetVersion :one
SELECT * FROM asset_versions WHERE asset_type = $1 AND asset_id = $2
ORDER BY version DESC LIMIT 1;
