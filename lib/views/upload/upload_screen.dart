import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/upload_viewmodel.dart';
import '../../viewmodels/artist_viewmodel.dart';
import '../../viewmodels/library_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UploadViewModel(
        context.read<ArtistViewModel>().repository,
        context.read<AuthViewModel>(),
      ),
      child: const _UploadBody(),
    );
  }
}

class _UploadBody extends StatelessWidget {
  const _UploadBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.onBackground),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Upload bài hát',
                style: TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _StepIndicator(step: vm.step),
              const Divider(height: 1),
              Expanded(
                child: vm.status == UploadStatus.uploading
                    ? _buildLoading()
                    : vm.status == UploadStatus.success
                        ? _buildSuccess(context, vm)
                        : _buildStep(context, vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 20),
          Text('Đang upload bài hát...',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, UploadViewModel vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 20),
          const Text('Upload thành công!',
              style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Bài hát "${vm.title}" đã được thêm vào thư viện',
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _OutlineBtn(
                label: 'Upload thêm',
                onTap: () {
                  vm.reset();
                  context.read<LibraryViewModel>().loadSongs();
                },
              ),
              const SizedBox(width: 12),
              _PrimaryBtn(
                label: 'Xong',
                onTap: () {
                  context.read<LibraryViewModel>().loadSongs();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, UploadViewModel vm) {
    switch (vm.step) {
      case UploadStep.songInfo:
        return _Step1SongInfo(vm: vm);
      case UploadStep.confirm:
        return _Step2Confirm(vm: vm);
    }
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final UploadStep step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    final steps = ['Thông tin', 'Xác nhận'];
    final current = step.index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: i ~/ 2 < current
                    ? AppColors.primary
                    : AppColors.divider,
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < current;
          final active = idx == current;
          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done || active
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : Center(
                        child: Text('${idx + 1}',
                            style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : AppColors.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
              ),
              const SizedBox(height: 4),
              Text(steps[idx],
                  style: TextStyle(
                      color: active
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
            ],
          );
        }),
      ),
    );
  }
}

// ── Step 1: Song Info ─────────────────────────────────────────────────────────
class _Step1SongInfo extends StatefulWidget {
  final UploadViewModel vm;
  const _Step1SongInfo({required this.vm});

  @override
  State<_Step1SongInfo> createState() => _Step1SongInfoState();
}

class _Step1SongInfoState extends State<_Step1SongInfo> {
  late final TextEditingController _titleCtrl;

  final List<String> _genres = [
    'Pop', 'Rock', 'Jazz', 'Electronic', 'Ambient',
    'Indie', 'R&B', 'Hip-hop', 'Classical', 'Khác'
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.vm.title);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Real file picker ───────────────────────────────
          GestureDetector(
            onTap: vm.isDetectingDuration ? null : vm.pickAudioFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: vm.hasAudioFile
                      ? AppColors.primary
                      : AppColors.divider,
                  width: 1.5,
                ),
              ),
              child: vm.isDetectingDuration
                  ? const Column(
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Đang đọc file...',
                            style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13)),
                      ],
                    )
                  : Column(
                      children: [
                        Icon(
                          vm.hasAudioFile
                              ? Icons.audio_file_rounded
                              : Icons.upload_file_rounded,
                          color: AppColors.primary,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          vm.hasAudioFile
                              ? vm.audioFileName!
                              : 'Chọn file âm thanh',
                          style: TextStyle(
                            color: vm.hasAudioFile
                                ? AppColors.onBackground
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vm.hasAudioFile
                              ? 'Thời lượng: ${vm.formatDuration(vm.durationSec)}'
                              : 'Hỗ trợ MP3, WAV, FLAC',
                          style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          _label('Tên bài hát *'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleCtrl,
            onChanged: vm.setTitle,
            style: const TextStyle(color: AppColors.onBackground),
            decoration: const InputDecoration(hintText: 'Nhập tên bài hát...'),
          ),
          const SizedBox(height: 16),
          _label('Thể loại'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _genres.map((g) {
              final selected = vm.genre == g;
              return GestureDetector(
                onTap: () => vm.setGenre(selected ? '' : g),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
                  child: Text(g,
                      style: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.onBackground,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          _PrimaryBtn(
            label: 'Tiếp theo →',
            disabled: !vm.canProceedStep1,
            onTap: vm.canProceedStep1 ? vm.nextStep : null,
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Confirm ───────────────────────────────────────────────────────────
class _Step2Confirm extends StatelessWidget {
  final UploadViewModel vm;
  const _Step2Confirm({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: AppColors.primary.withOpacity(0.15),
                    child: const Icon(Icons.music_note_rounded,
                        color: AppColors.primary, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vm.title,
                          style: const TextStyle(
                              color: AppColors.onBackground,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(vm.uploaderName,
                          style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoRow(label: 'Artist', value: vm.uploaderName),
          _InfoRow(label: 'Thể loại', value: vm.genre.isEmpty ? '—' : vm.genre),
          _InfoRow(label: 'Thời lượng', value: vm.formatDuration(vm.durationSec)),

          if (vm.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(vm.errorMessage!,
                  style: const TextStyle(
                      color: Colors.redAccent, fontSize: 13)),
            ),

          const SizedBox(height: 32),
          Row(
            children: [
              _OutlineBtn(label: '← Quay lại', onTap: vm.prevStep),
              const SizedBox(width: 12),
              Expanded(
                child: _PrimaryBtn(
                  label: 'Upload ngay',
                  onTap: () async => vm.submit(),
                  icon: Icons.cloud_upload_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool disabled;
  final IconData? icon;

  const _PrimaryBtn({
    required this.label,
    this.onTap,
    this.disabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.surfaceVariant
              : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: TextStyle(
                    color: disabled
                        ? AppColors.onSurfaceVariant
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 14)),
      ),
    );
  }
}

Widget _label(String text) => Text(
      text,
      style: const TextStyle(
          color: AppColors.onBackground,
          fontSize: 14,
          fontWeight: FontWeight.w600),
    );
