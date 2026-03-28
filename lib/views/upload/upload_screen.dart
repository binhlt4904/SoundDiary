import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/upload_viewmodel.dart';
import '../../viewmodels/artist_viewmodel.dart';
import '../../viewmodels/library_viewmodel.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/album.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UploadViewModel(
        context.read<ArtistViewModel>().repository,
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
      case UploadStep.artistAlbum:
        return _Step2ArtistAlbum(vm: vm);
      case UploadStep.confirm:
        return _Step3Confirm(vm: vm);
    }
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final UploadStep step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    final steps = ['Thông tin', 'Artist & Album', 'Xác nhận'];
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
  late final TextEditingController _genreCtrl;

  final List<String> _genres = [
    'Pop', 'Rock', 'Jazz', 'Electronic', 'Ambient',
    'Indie', 'R&B', 'Hip-hop', 'Classical', 'Khác'
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.vm.title);
    _genreCtrl = TextEditingController(text: widget.vm.genre);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _genreCtrl.dispose();
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
          // Fake file picker
          GestureDetector(
            onTap: () => vm.setAudioPath('mock_audio.mp3'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: vm.coverUrl != null
                      ? AppColors.primary
                      : AppColors.divider,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.audio_file_rounded,
                    color: AppColors.primary.withOpacity(0.8),
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text('Chọn file MP3',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Hỗ trợ MP3, WAV, FLAC',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12)),
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
                onTap: () {
                  vm.setGenre(selected ? '' : g);
                  _genreCtrl.text = selected ? '' : g;
                },
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
          const SizedBox(height: 16),
          _label('Thời lượng (giây)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: vm.durationSec.toDouble(),
                  min: 30,
                  max: 600,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.surfaceVariant,
                  onChanged: (v) => vm.setDuration(v.round()),
                ),
              ),
              const SizedBox(width: 12),
              Text(vm.formatDuration(vm.durationSec),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
            ],
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

// ── Step 2: Artist & Album ────────────────────────────────────────────────────
class _Step2ArtistAlbum extends StatefulWidget {
  final UploadViewModel vm;
  const _Step2ArtistAlbum({required this.vm});

  @override
  State<_Step2ArtistAlbum> createState() => _Step2ArtistAlbumState();
}

class _Step2ArtistAlbumState extends State<_Step2ArtistAlbum> {
  final _artistCtrl = TextEditingController();
  final _albumCtrl = TextEditingController();
  String _artistSearch = '';

  @override
  void dispose() {
    _artistCtrl.dispose();
    _albumCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final artistVm = context.watch<ArtistViewModel>();
    final filteredArtists = artistVm.searchArtists(_artistSearch);
    final artistAlbums = vm.selectedArtist != null
        ? artistVm.albumsOf(vm.selectedArtist!.id)
        : <Album>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Artist ──────────────────────────────────────────
          _label('Artist *'),
          const SizedBox(height: 10),
          // Toggle: chọn có sẵn vs tạo mới
          Row(
            children: [
              _TabBtn(
                label: 'Chọn có sẵn',
                active: !vm.createNewArtist,
                onTap: () => vm.setCreateNewArtist(false),
              ),
              const SizedBox(width: 8),
              _TabBtn(
                label: '+ Tạo mới',
                active: vm.createNewArtist,
                onTap: () => vm.setCreateNewArtist(true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!vm.createNewArtist) ...[
            TextField(
              onChanged: (v) => setState(() => _artistSearch = v),
              style: const TextStyle(color: AppColors.onBackground),
              decoration: const InputDecoration(
                hintText: 'Tìm artist...',
                prefixIcon: Icon(Icons.search, size: 18),
              ),
            ),
            const SizedBox(height: 8),
            ...filteredArtists.map((a) => _SelectTile(
                  title: a.name,
                  subtitle: a.bio,
                  selected: vm.selectedArtist?.id == a.id,
                  onTap: () => vm.selectArtist(a),
                )),
          ] else ...[
            TextField(
              controller: _artistCtrl,
              onChanged: vm.setNewArtistName,
              style: const TextStyle(color: AppColors.onBackground),
              decoration: const InputDecoration(
                  hintText: 'Tên artist mới...'),
            ),
          ],

          const SizedBox(height: 24),

          // ── Album ────────────────────────────────────────────
          _label('Album'),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!vm.createNewArtist && vm.selectedArtist != null) ...[
                _TabBtn(
                  label: 'Chọn album',
                  active: !vm.createNewAlbum && !vm.noAlbum,
                  onTap: () {
                    vm.setCreateNewAlbum(false);
                    vm.setNoAlbum(false);
                  },
                ),
                const SizedBox(width: 8),
              ],
              _TabBtn(
                label: '+ Tạo album',
                active: vm.createNewAlbum,
                onTap: () => vm.setCreateNewAlbum(true),
              ),
              const SizedBox(width: 8),
              _TabBtn(
                label: 'Không có',
                active: vm.noAlbum,
                onTap: () => vm.setNoAlbum(true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (vm.noAlbum)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Bài hát sẽ không thuộc album nào.',
                  style: TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 13)),
            )
          else if (vm.createNewAlbum) ...[
            TextField(
              controller: _albumCtrl,
              onChanged: vm.setNewAlbumTitle,
              style: const TextStyle(color: AppColors.onBackground),
              decoration:
                  const InputDecoration(hintText: 'Tên album mới...'),
            ),
          ] else if (artistAlbums.isNotEmpty) ...[
            ...artistAlbums.map((a) => _SelectTile(
                  title: a.title,
                  subtitle: a.releasedAt != null
                      ? '${a.releasedAt!.year}'
                      : null,
                  selected: vm.selectedAlbum?.id == a.id,
                  onTap: () => vm.selectAlbum(a),
                )),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                  'Artist này chưa có album. Tạo mới hoặc bỏ qua.',
                  style: TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 13)),
            ),
          ],

          const SizedBox(height: 32),
          Row(
            children: [
              _OutlineBtn(label: '← Quay lại', onTap: vm.prevStep),
              const SizedBox(width: 12),
              Expanded(
                child: _PrimaryBtn(
                  label: 'Tiếp theo →',
                  disabled: !vm.canProceedStep2,
                  onTap: vm.canProceedStep2 ? vm.nextStep : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Confirm ───────────────────────────────────────────────────────────
class _Step3Confirm extends StatelessWidget {
  final UploadViewModel vm;
  const _Step3Confirm({required this.vm});

  @override
  Widget build(BuildContext context) {
    final artistVm = context.read<ArtistViewModel>();
    final artistName = vm.createNewArtist
        ? '${vm.newArtistName} (mới)'
        : vm.selectedArtist?.name ?? '—';
    final albumName = vm.noAlbum
        ? 'Không có'
        : vm.createNewAlbum
            ? '${vm.newAlbumTitle} (mới)'
            : vm.selectedAlbum?.title ?? '—';

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
                      Text(artistName,
                          style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13)),
                      if (!vm.noAlbum)
                        Text(albumName,
                            style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _InfoRow(label: 'Thể loại', value: vm.genre.isEmpty ? '—' : vm.genre),
          _InfoRow(label: 'Thời lượng', value: vm.formatDuration(vm.durationSec)),
          _InfoRow(label: 'Artist', value: artistName),
          _InfoRow(label: 'Album', value: albumName),

          if (vm.createNewArtist)
            _Notice('Artist "${vm.newArtistName}" sẽ được tạo mới'),
          if (vm.createNewAlbum)
            _Notice('Album "${vm.newAlbumTitle}" sẽ được tạo mới'),

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
class _SelectTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectTile({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.onBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : AppColors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

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

class _Notice extends StatelessWidget {
  final String text;
  const _Notice(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.primary, fontSize: 12)),
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
