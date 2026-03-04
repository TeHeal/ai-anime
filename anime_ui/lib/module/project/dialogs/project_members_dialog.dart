import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/project_member.dart';
import 'package:anime_ui/pub/providers/project_member_provider.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/job_role_chip.dart';

/// 项目成员管理对话框 — 用于 AppDialog.show 内
class ProjectMembersDialog extends ConsumerStatefulWidget {
  final String projectId;
  final VoidCallback onClose;

  const ProjectMembersDialog({
    super.key,
    required this.projectId,
    required this.onClose,
  });

  @override
  ConsumerState<ProjectMembersDialog> createState() =>
      _ProjectMembersDialogState();
}

class _ProjectMembersDialogState extends ConsumerState<ProjectMembersDialog> {
  final _userIdCtrl = TextEditingController();
  String _addRole = 'editor';
  List<String> _addJobRoles = [];
  bool _adding = false;

  @override
  void dispose() {
    _userIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    final userId = _userIdCtrl.text.trim();
    if (userId.isEmpty) {
      showToast(context, '请输入用户 ID', isError: true);
      return;
    }
    setState(() => _adding = true);
    try {
      await ref.read(projectMemberActionsProvider).addMember(
            widget.projectId,
            userId: userId,
            role: _addRole,
            jobRoles: _addJobRoles,
          );
      ref.invalidate(projectMembersProvider(widget.projectId));
      _userIdCtrl.clear();
      setState(() => _addJobRoles = []);
      if (mounted) showToast(context, '成员已添加');
    } catch (e) {
      if (mounted) showToast(context, '添加失败: $e', isError: true);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(projectMembersProvider(widget.projectId));

    return Padding(
      padding: EdgeInsets.all(Spacing.xl.w),
      child: SizedBox(
        width: 560.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: Spacing.lg.h),
            _buildAddForm(),
            SizedBox(height: Spacing.lg.h),
            _buildSectionTitle(membersAsync),
            SizedBox(height: Spacing.sm.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 360.h),
              child: membersAsync.when(
                data: (members) => _buildMemberList(members),
                loading: () => Center(
                  child: Padding(
                    padding: EdgeInsets.all(Spacing.xl.w),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    '加载失败: $e',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Spacing.sm.w),
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          ),
          child: Icon(
            AppIcons.people,
            size: Spacing.mid.r,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: Spacing.md.w),
        Text(
          '项目成员',
          style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
        ),
        const Spacer(),
        IconButton(
          onPressed: widget.onClose,
          icon: Icon(AppIcons.close, size: Spacing.mid.r, color: AppColors.mutedDark),
          splashRadius: Spacing.lg.r,
        ),
      ],
    );
  }

  Widget _buildAddForm() {
    return Container(
      padding: EdgeInsets.all(Spacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '邀请成员',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: Spacing.md.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _userIdCtrl,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: '用户 ID 或用户名',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mutedDark,
                    ),
                    prefixIcon: Icon(
                      AppIcons.person,
                      size: Spacing.menuIconSize.r,
                      color: AppColors.muted,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Spacing.md.w,
                      vertical: Spacing.buttonPaddingV.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              // 层级角色选择
              _buildRoleDropdown(),
              SizedBox(width: Spacing.sm.w),
              FilledButton.icon(
                onPressed: _adding ? null : _addMember,
                icon: _adding
                    ? SizedBox(
                        width: Spacing.gridGap.w,
                        height: Spacing.gridGap.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Icon(AppIcons.add, size: Spacing.gridGap.r),
                label: Text(
                  '添加',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.4),
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.lg.w,
                    vertical: Spacing.buttonPaddingV.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.md.h),
          Text(
            '工种',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: Spacing.xs.h),
          JobRoleSelector(
            selected: _addJobRoles,
            onChanged: (v) => setState(() => _addJobRoles = v),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _addRole,
          isDense: true,
          dropdownColor: AppColors.surfaceContainerHigh,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurface,
          ),
          items: const [
            DropdownMenuItem(value: 'director', child: Text('导演')),
            DropdownMenuItem(value: 'editor', child: Text('编辑者')),
            DropdownMenuItem(value: 'viewer', child: Text('查看者')),
          ],
          onChanged: (v) => setState(() => _addRole = v ?? 'editor'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(AsyncValue<List<ProjectMember>> membersAsync) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: Spacing.gridGap.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: Spacing.sm.w),
        Text(
          '当前成员',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: Spacing.sm.w),
        if (membersAsync.hasValue)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w,
              vertical: Spacing.xxs.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            ),
            child: Text(
              '${membersAsync.value?.length ?? 0}',
              style: AppTextStyles.labelTinySmall.copyWith(
                color: AppColors.muted,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMemberList(List<ProjectMember> members) {
    if (members.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Spacing.xxl.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.people, size: 40.r, color: AppColors.mutedDarker),
              SizedBox(height: Spacing.md.h),
              Text(
                '暂无成员',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
              SizedBox(height: Spacing.xs.h),
              Text(
                '在上方邀请第一个成员',
                style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: members.length,
      separatorBuilder: (_, __) => SizedBox(height: Spacing.sm.h),
      itemBuilder: (_, i) => _MemberCard(
        member: members[i],
        projectId: widget.projectId,
      ),
    );
  }
}

/// 单个成员卡片 — 显示头像、名称、角色、工种（可编辑）、移除
class _MemberCard extends ConsumerStatefulWidget {
  final ProjectMember member;
  final String projectId;

  const _MemberCard({required this.member, required this.projectId});

  @override
  ConsumerState<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends ConsumerState<_MemberCard> {
  late List<String> _jobRoles;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _jobRoles = List.from(widget.member.jobRoles);
  }

  @override
  void didUpdateWidget(covariant _MemberCard old) {
    super.didUpdateWidget(old);
    if (old.member.jobRoles != widget.member.jobRoles) {
      _jobRoles = List.from(widget.member.jobRoles);
      _dirty = false;
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(projectMemberActionsProvider).updateJobRoles(
            widget.projectId,
            widget.member.userId,
            _jobRoles,
          );
      ref.invalidate(projectMembersProvider(widget.projectId));
      if (mounted) {
        setState(() => _dirty = false);
        showToast(context, '工种已更新');
      }
    } catch (e) {
      if (mounted) showToast(context, '保存失败: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('移除成员', style: AppTextStyles.h4.copyWith(color: AppColors.onSurface)),
        content: Text(
          '确定要移除 ${widget.member.username.isNotEmpty ? widget.member.username : widget.member.userId} 吗？',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('取消', style: AppTextStyles.labelLarge.copyWith(color: AppColors.muted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('移除', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(projectMemberActionsProvider).removeMember(
            widget.projectId,
            widget.member.userId,
          );
      ref.invalidate(projectMembersProvider(widget.projectId));
      if (mounted) showToast(context, '成员已移除');
    } catch (e) {
      if (mounted) showToast(context, '移除失败: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final isOwner = m.isOwner;
    final name = m.username.isNotEmpty ? m.username : m.userId;

    return Container(
      padding: EdgeInsets.all(Spacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 头像
              Container(
                width: Spacing.xxl.w,
                height: Spacing.xxl.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isOwner
                        ? [
                            AppColors.primary.withValues(alpha: 0.6),
                            AppColors.primary,
                          ]
                        : [
                            AppColors.surfaceContainerHighest,
                            AppColors.surfaceMuted,
                          ],
                  ),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isOwner
                          ? AppColors.onPrimary
                          : AppColors.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (m.displayName.isNotEmpty)
                      Text(
                        m.displayName,
                        style: AppTextStyles.tiny.copyWith(color: AppColors.muted),
                      ),
                  ],
                ),
              ),
              // 角色徽章
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm.w,
                  vertical: Spacing.xs.h,
                ),
                decoration: BoxDecoration(
                  color: isOwner
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                ),
                child: Text(
                  _roleLabel(m.role),
                  style: AppTextStyles.labelTinySmall.copyWith(
                    color: isOwner ? AppColors.primary : AppColors.muted,
                    fontWeight: isOwner ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (!isOwner) ...[
                SizedBox(width: Spacing.xs.w),
                IconButton(
                  onPressed: _remove,
                  icon: Icon(
                    AppIcons.delete,
                    size: Spacing.menuIconSize.r,
                    color: AppColors.error.withValues(alpha: 0.6),
                  ),
                  splashRadius: Spacing.lg.r,
                  tooltip: '移除成员',
                ),
              ],
            ],
          ),
          SizedBox(height: Spacing.sm.h),
          // 工种选择
          Row(
            children: [
              Expanded(
                child: JobRoleSelector(
                  selected: _jobRoles,
                  readOnly: isOwner,
                  onChanged: (v) {
                    setState(() {
                      _jobRoles = v;
                      _dirty = true;
                    });
                  },
                ),
              ),
              if (_dirty && !isOwner) ...[
                SizedBox(width: Spacing.sm.w),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.md.w,
                      vertical: Spacing.chipPaddingV.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                    ),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: Spacing.gridGap.w,
                          height: Spacing.gridGap.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          '保存',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) => switch (role) {
        'owner' => '所有者',
        'director' => '导演',
        'editor' => '编辑者',
        'viewer' => '查看者',
        _ => role,
      };
}
