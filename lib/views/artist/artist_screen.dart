import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/album.dart';
import '../../viewmodels/artist_viewmodel.dart';

class ArtistScreen extends StatefulWidget {
  const ArtistScreen({super.key});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.onBackground, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Artist & Album'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Artists'),
            Tab(text: 'Albums'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _ArtistTab(),
          _AlbumTab(),
        ],
      ),
    );
  }
}

// ── Artist Tab ────────────────────────────────────────────────────────────────
class _ArtistTab extends StatefulWidget {
  const _ArtistTab();

  @override
  State<_ArtistTab> createState() => _ArtistTabState();
}

class _ArtistTabState extends State<_ArtistTab> {
  String _search = '';

  void _showArtistDialog(BuildContext context, {Artist? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final bioCtrl = TextEditingController(text: existing?.bio ?? '');
    final vm = context.read<ArtistViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(existing == null ? 'Tạo Artist mới' : 'Sửa Artist',
            style: const TextStyle(color: AppColors.onBackground)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppColors.onBackground),
              decoration: const InputDecoration(hintText: 'Tên artist *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioCtrl,
              style: const TextStyle(color: AppColors.onBackground),
              decoration: const InputDecoration(hintText: 'Mô tả (tuỳ chọn)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              if (existing == null) {
                vm.createArtist(
                    name: nameCtrl.text.trim(),
                    bio: bioCtrl.text.trim().isEmpty
                        ? null
                        : bioCtrl.text.trim());
              } else {
                vm.updateArtist(existing.copyWith(
                    name: nameCtrl.text.trim(),
                    bio: bioCtrl.text.trim().isEmpty
                        ? null
                        : bioCtrl.text.trim()));
              }
              Navigator.pop(ctx);
            },
            child: Text(existing == null ? 'Tạo' : 'Lưu',
                style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Artist artist) {
    final vm = context.read<ArtistViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa Artist?',
            style: TextStyle(color: AppColors.onBackground)),
        content: Text(
            'Xóa "${artist.name}" sẽ xóa tất cả bài hát và album của artist này.',
            style: const TextStyle(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              vm.deleteArtist(artist.id);
              Navigator.pop(ctx);
            },
            child: const Text('Xóa',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtistViewModel>(
      builder: (context, vm, _) {
        final artists = vm.searchArtists(_search);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: const TextStyle(color: AppColors.onBackground),
                      decoration: const InputDecoration(
                          hintText: 'Tìm artist...',
                          prefixIcon: Icon(Icons.search, size: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showArtistDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: artists.isEmpty
                  ? const Center(
                      child: Text('Chưa có artist',
                          style: TextStyle(
                              color: AppColors.onSurfaceVariant)))
                  : ListView.builder(
                      itemCount: artists.length,
                      itemBuilder: (context, i) {
                        final a = artists[i];
                        final albumCount = vm.albumsOf(a.id).length;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withOpacity(0.15),
                            child: Text(a.name[0].toUpperCase(),
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                          ),
                          title: Text(a.name,
                              style: const TextStyle(
                                  color: AppColors.onBackground,
                                  fontWeight: FontWeight.w500)),
                          subtitle: Text(
                              a.bio != null
                                  ? '${a.bio} • $albumCount album'
                                  : '$albumCount album',
                              style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: AppColors.onSurfaceVariant,
                                    size: 18),
                                onPressed: () =>
                                    _showArtistDialog(context, existing: a),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 18),
                                onPressed: () =>
                                    _confirmDelete(context, a),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Album Tab ─────────────────────────────────────────────────────────────────
class _AlbumTab extends StatefulWidget {
  const _AlbumTab();

  @override
  State<_AlbumTab> createState() => _AlbumTabState();
}

class _AlbumTabState extends State<_AlbumTab> {
  String _search = '';

  void _showAlbumDialog(BuildContext context, {Album? existing}) {
    final vm = context.read<ArtistViewModel>();
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    Artist? selectedArtist = existing != null
        ? vm.artists.firstWhere((a) => a.id == existing.artistId,
            orElse: () => vm.artists.first)
        : (vm.artists.isNotEmpty ? vm.artists.first : null);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.surfaceVariant,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(existing == null ? 'Tạo Album mới' : 'Sửa Album',
              style: const TextStyle(color: AppColors.onBackground)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppColors.onBackground),
                decoration:
                    const InputDecoration(hintText: 'Tên album *'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Artist>(
                value: selectedArtist,
                dropdownColor: AppColors.surfaceVariant,
                decoration: InputDecoration(
                  labelText: 'Artist',
                  labelStyle: const TextStyle(
                      color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: AppColors.onBackground),
                items: vm.artists.map((a) {
                  return DropdownMenuItem(
                    value: a,
                    child: Text(a.name),
                  );
                }).toList(),
                onChanged: (a) => setS(() => selectedArtist = a),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy',
                  style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty ||
                    selectedArtist == null) return;
                if (existing == null) {
                  vm.createAlbum(
                      title: titleCtrl.text.trim(),
                      artistId: selectedArtist!.id);
                } else {
                  vm.updateAlbum(existing.copyWith(
                      title: titleCtrl.text.trim(),
                      artistId: selectedArtist!.id));
                }
                Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Tạo' : 'Lưu',
                  style: const TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtistViewModel>(
      builder: (context, vm, _) {
        final albums = vm.searchAlbums(_search);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style:
                          const TextStyle(color: AppColors.onBackground),
                      decoration: const InputDecoration(
                          hintText: 'Tìm album...',
                          prefixIcon: Icon(Icons.search, size: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: vm.artists.isEmpty
                        ? null
                        : () => _showAlbumDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: vm.artists.isEmpty
                            ? AppColors.surfaceVariant
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: albums.isEmpty
                  ? const Center(
                      child: Text('Chưa có album',
                          style: TextStyle(
                              color: AppColors.onSurfaceVariant)))
                  : ListView.builder(
                      itemCount: albums.length,
                      itemBuilder: (context, i) {
                        final al = albums[i];
                        final artist = vm.artists.firstWhere(
                            (a) => a.id == al.artistId,
                            orElse: () =>
                                Artist(id: '', name: 'Unknown'));
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 44,
                              color: AppColors.primary.withOpacity(0.15),
                              child: const Icon(
                                  Icons.album_rounded,
                                  color: AppColors.primary,
                                  size: 22),
                            ),
                          ),
                          title: Text(al.title,
                              style: const TextStyle(
                                  color: AppColors.onBackground,
                                  fontWeight: FontWeight.w500)),
                          subtitle: Text(
                              '${artist.name}${al.releasedAt != null ? ' • ${al.releasedAt!.year}' : ''}',
                              style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: AppColors.onSurfaceVariant,
                                    size: 18),
                                onPressed: () => _showAlbumDialog(
                                    context,
                                    existing: al),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent,
                                    size: 18),
                                onPressed: () =>
                                    vm.deleteAlbum(al.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
