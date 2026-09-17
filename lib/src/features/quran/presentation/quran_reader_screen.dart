import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/state_views.dart';
import '../application/quran_controller.dart';
import '../domain/quran_models.dart';

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({
    super.key,
    required this.controller,
    required this.surahId,
    this.initialAyahNumber,
  });

  final QuranController controller;
  final int surahId;
  final int? initialAyahNumber;

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _ayahKeys = {};
  final Map<int, GlobalKey> _surahKeys = {};

  List<Surah> _allSurahs = [];
  List<Surah> _displayedSurahs = [];
  late Surah _currentVisibleSurah;
  bool _isLoading = true;
  String? _errorMessage;

  late double _fontSize;
  late bool _isMushafMode;
  int? _selectedAyahNumber;
  int? _selectedSurahId;
  bool _didScrollToInitialAyah = false;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.controller.getFontSize();
    _isMushafMode = widget.controller.getMushafMode();
    _selectedAyahNumber = widget.initialAyahNumber;
    _selectedSurahId = widget.surahId;

    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final surahs = await widget.controller.loadSurahs();
      if (!mounted) return;

      final initialIndex = surahs.indexWhere((s) => s.id == widget.surahId);
      final validIndex = initialIndex >= 0 ? initialIndex : 0;
      final initialSurah = surahs[validIndex];

      setState(() {
        _allSurahs = surahs;
        _displayedSurahs = [initialSurah];
        _currentVisibleSurah = initialSurah;
        _isLoading = false;
      });

      _scheduleInitialAyahScroll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // 1. Continuous scroll: Append next surah when approaching bottom
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 600) {
      _appendNextSurah();
    }

    // 2. Track which surah is currently visible in viewport to update AppBar title
    _updateVisibleSurahTitle();
  }

  void _appendNextSurah() {
    if (_displayedSurahs.isEmpty || _allSurahs.isEmpty) return;
    final lastDisplayed = _displayedSurahs.last;
    final nextIndex = _allSurahs.indexWhere((s) => s.id == lastDisplayed.id) + 1;

    if (nextIndex < _allSurahs.length) {
      final nextSurah = _allSurahs[nextIndex];
      if (!_displayedSurahs.any((s) => s.id == nextSurah.id)) {
        setState(() {
          _displayedSurahs.add(nextSurah);
        });
      }
    }
  }

  void _updateVisibleSurahTitle() {
    for (final surah in _displayedSurahs.reversed) {
      final key = _surahKeys[surah.id];
      final context = key?.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final pos = box.localToGlobal(Offset.zero);
          if (pos.dy <= 240) {
            if (_currentVisibleSurah.id != surah.id) {
              setState(() {
                _currentVisibleSurah = surah;
              });
            }
            break;
          }
        }
      }
    }
  }

  void _scheduleInitialAyahScroll() {
    if (_didScrollToInitialAyah || widget.initialAyahNumber == null) return;
    _didScrollToInitialAyah = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _ayahKeys['${widget.surahId}-${widget.initialAyahNumber}'];
      final context = key?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          alignment: 0.15,
        );
      }
    });
  }

  void _onAyahTapped(Surah surah, Ayah ayah) {
    setState(() {
      _selectedSurahId = surah.id;
      _selectedAyahNumber = ayah.number;
    });
    widget.controller.saveLastRead(surah, ayah);
    _showAyahActionSheet(surah, ayah);
  }

  void _showAyahActionSheet(Surah surah, Ayah ayah) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayText = _getAyahTextWithoutBasmalah(surah.id, ayah.number, ayah.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${surah.name} • آية ${_arabicDigits(ayah.number)}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (ayah.juz != null)
                      Text(
                        'الجزء ${_arabicDigits(ayah.juz!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    displayText,
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.titleMedium?.copyWith(
                      height: 1.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.bookmark_add_outlined,
                      label: 'حفظ علامة',
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await widget.controller.bookmark(surah, ayah);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم حفظ علامة عند ${surah.name} آية ${_arabicDigits(ayah.number)}',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    _ActionButton(
                      icon: Icons.bookmark_border,
                      label: 'موضع قراءة',
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await widget.controller.saveLastRead(surah, ayah);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم حفظ موضع القراءة عند آية ${_arabicDigits(ayah.number)}',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    _ActionButton(
                      icon: Icons.copy_rounded,
                      label: 'نسخ الآية',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                '$displayText ﴿${surah.name}: ${ayah.number}﴾',
                          ),
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ نص الآية')),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFontSizeDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'حجم خط المصحف',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _fontSize > 18.0
                              ? () {
                                  final newSize = _fontSize - 2.0;
                                  setModalState(() => _fontSize = newSize);
                                  setState(() => _fontSize = newSize);
                                  widget.controller.setFontSize(newSize);
                                }
                              : null,
                        ),
                        Expanded(
                          child: Slider(
                            value: _fontSize,
                            min: 18.0,
                            max: 36.0,
                            divisions: 9,
                            label: '${_fontSize.round()}',
                            onChanged: (val) {
                              setModalState(() => _fontSize = val);
                              setState(() => _fontSize = val);
                              widget.controller.setFontSize(val);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _fontSize < 36.0
                              ? () {
                                  final newSize = _fontSize + 2.0;
                                  setModalState(() => _fontSize = newSize);
                                  setState(() => _fontSize = newSize);
                                  widget.controller.setFontSize(newSize);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSurahJumpPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (pickerContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'الانتقال إلى سورة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _allSurahs.length,
                    itemBuilder: (context, index) {
                      final surah = _allSurahs[index];
                      final isSelected = surah.id == _currentVisibleSurah.id;
                      return ListTile(
                        selected: isSelected,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.12),
                          child: Text(
                            '${surah.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          surah.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${surah.revelationLabel} • ${surah.ayahs.length} آيات',
                        ),
                        onTap: () {
                          Navigator.pop(pickerContext);
                          _jumpToSurah(surah);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _jumpToSurah(Surah surah) {
    setState(() {
      _displayedSurahs = [surah];
      _currentVisibleSurah = surah;
      _selectedAyahNumber = null;
      _selectedSurahId = surah.id;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingView());
    }
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorStateView(message: _errorMessage!),
      );
    }
    if (_displayedSurahs.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(message: 'السورة غير موجودة'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentVisibleSurah.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'الانتقال إلى سورة',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: _showSurahJumpPicker,
          ),
          IconButton(
            tooltip: _isMushafMode ? 'عرض الآيات كبطاقات' : 'عرض المصحف المتصل',
            icon: Icon(
              _isMushafMode
                  ? Icons.view_agenda_outlined
                  : Icons.auto_stories_outlined,
            ),
            onPressed: () {
              final newMode = !_isMushafMode;
              setState(() => _isMushafMode = newMode);
              widget.controller.setMushafMode(newMode);
            },
          ),
          IconButton(
            tooltip: 'حجم الخط',
            icon: const Icon(Icons.format_size_rounded),
            onPressed: _showFontSizeDialog,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
            itemCount: _displayedSurahs.length,
            itemBuilder: (context, index) {
              final surah = _displayedSurahs[index];
              final surahKey = _surahKeys.putIfAbsent(surah.id, GlobalKey.new);
              final isLastDisplayed = index == _displayedSurahs.length - 1;
              final hasNextSurah =
                  _allSurahs.indexWhere((s) => s.id == surah.id) + 1 <
                  _allSurahs.length;
              final nextSurah = hasNextSurah
                  ? _allSurahs[
                      _allSurahs.indexWhere((s) => s.id == surah.id) + 1]
                  : null;

              return KeyedSubtree(
                key: surahKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (index > 0) const SizedBox(height: 36),
                    _SurahHeader(surah: surah),
                    const SizedBox(height: 14),
                    if (surah.id != 9 && surah.id != 1) ...[
                      const _BasmalahBanner(),
                      const SizedBox(height: 14),
                    ],
                    if (_isMushafMode)
                      _MushafContinuousView(
                        surah: surah,
                        fontSize: _fontSize,
                        selectedAyahNumber: _selectedSurahId == surah.id
                            ? _selectedAyahNumber
                            : null,
                        ayahKeys: _ayahKeys,
                        onAyahTapped: (ayah) => _onAyahTapped(surah, ayah),
                      )
                    else
                      _AyahByAyahView(
                        surah: surah,
                        fontSize: _fontSize,
                        selectedAyahNumber: _selectedSurahId == surah.id
                            ? _selectedAyahNumber
                            : null,
                        ayahKeys: _ayahKeys,
                        onAyahTapped: (ayah) => _onAyahTapped(surah, ayah),
                      ),
                    const SizedBox(height: 24),
                    if (nextSurah != null)
                      _SurahTransitionBanner(
                        currentSurah: surah,
                        nextSurah: nextSurah,
                        onContinueTap: isLastDisplayed ? _appendNextSurah : null,
                      )
                    else if (surah.id == 114)
                      const _KhatmQuranCard(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MushafContinuousView extends StatelessWidget {
  const _MushafContinuousView({
    required this.surah,
    required this.fontSize,
    required this.selectedAyahNumber,
    required this.ayahKeys,
    required this.onAyahTapped,
  });

  final Surah surah;
  final double fontSize;
  final int? selectedAyahNumber;
  final Map<String, GlobalKey> ayahKeys;
  final void Function(Ayah ayah) onAyahTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildAyahSections(context),
        ),
      ),
    );
  }

  List<Widget> _buildAyahSections(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const chunkSize = 6;
    final widgets = <Widget>[];

    for (var i = 0; i < surah.ayahs.length; i += chunkSize) {
      final end = (i + chunkSize > surah.ayahs.length)
          ? surah.ayahs.length
          : i + chunkSize;
      final chunk = surah.ayahs.sublist(i, end);
      final firstAyah = chunk.first;

      final key = ayahKeys.putIfAbsent(
        '${surah.id}-${firstAyah.number}',
        GlobalKey.new,
      );
      for (final a in chunk) {
        ayahKeys['${surah.id}-${a.number}'] = key;
      }

      final hasSelected = chunk.any((a) => a.number == selectedAyahNumber);

      widgets.add(
        Container(
          key: key,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: hasSelected
                ? colorScheme.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                for (final ayah in chunk) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onAyahTapped(ayah),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 1,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: _getAyahTextWithoutBasmalah(
                                  surah.id,
                                  ayah.number,
                                  ayah.text,
                                ),
                              ),
                              TextSpan(
                                text: ' ﴿${_arabicDigits(ayah.number)}﴾ ',
                                style: TextStyle(
                                  color: colorScheme.secondary,
                                  fontSize: fontSize * 0.88,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: fontSize,
                            height: 2.2,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }
    return widgets;
  }
}

class _AyahByAyahView extends StatelessWidget {
  const _AyahByAyahView({
    required this.surah,
    required this.fontSize,
    required this.selectedAyahNumber,
    required this.ayahKeys,
    required this.onAyahTapped,
  });

  final Surah surah;
  final double fontSize;
  final int? selectedAyahNumber;
  final Map<String, GlobalKey> ayahKeys;
  final void Function(Ayah ayah) onAyahTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final ayah in surah.ayahs) ...[
          Builder(
            builder: (context) {
              final key = ayahKeys.putIfAbsent(
                '${surah.id}-${ayah.number}',
                GlobalKey.new,
              );
              final isSelected = ayah.number == selectedAyahNumber;
              final text = _getAyahTextWithoutBasmalah(
                surah.id,
                ayah.number,
                ayah.text,
              );

              return Card(
                key: key,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.08)
                    : null,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onAyahTapped(ayah),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _arabicDigits(ayah.number),
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (ayah.juz != null)
                              Text(
                                'جزء ${_arabicDigits(ayah.juz!)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: fontSize,
                            height: 2.1,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firstAyah = surah.ayahs.firstOrNull;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '۞',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                surah.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '۞',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _HeaderBadge(
                icon: Icons.place_outlined,
                label: surah.revelationLabel,
              ),
              _HeaderBadge(
                icon: Icons.format_list_numbered_rounded,
                label: '${_arabicDigits(surah.ayahs.length)} آيات',
              ),
              if (firstAyah?.juz != null)
                _HeaderBadge(
                  icon: Icons.auto_stories_outlined,
                  label: 'الجزء ${_arabicDigits(firstAyah!.juz!)}',
                ),
              if (firstAyah?.page != null)
                _HeaderBadge(
                  icon: Icons.description_outlined,
                  label: 'الصفحة ${_arabicDigits(firstAyah!.page!)}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BasmalahBanner extends StatelessWidget {
  const _BasmalahBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: theme.textTheme.titleLarge?.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SurahTransitionBanner extends StatelessWidget {
  const _SurahTransitionBanner({
    required this.currentSurah,
    required this.nextSurah,
    this.onContinueTap,
  });

  final Surah currentSurah;
  final Surah nextSurah;
  final VoidCallback? onContinueTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'تمّت بحمد الله ${currentSurah.name}',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'التالية: ${nextSurah.name} (${nextSurah.revelationLabel} • ${_arabicDigits(nextSurah.ayahs.length)} آيات)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (onContinueTap != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onContinueTap,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              label: Text('متابعة إلى ${nextSurah.name}'),
            ),
          ],
        ],
      ),
    );
  }
}

class _KhatmQuranCard extends StatelessWidget {
  const _KhatmQuranCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.secondary),
      ),
      child: Column(
        children: [
          Text(
            '﴿ صَدَقَ اللَّهُ الْعَظِيمُ ﴾',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'تم بحمد الله ختام المصحف الشريف، تقبل الله منا ومنكم صالح الأعمال.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

String _arabicDigits(int value) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return value
      .toString()
      .split('')
      .map((digit) => digits[int.parse(digit)])
      .join();
}

String _stripBOM(String text) {
  return text.replaceAll('\ufeff', '').trim();
}

const String _basmalahUthmani = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
const String _basmalahPlain = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

String _getAyahTextWithoutBasmalah(int surahId, int ayahNumber, String text) {
  final clean = _stripBOM(text);
  if (surahId == 1 || surahId == 9 || ayahNumber != 1) {
    return clean;
  }
  if (clean.startsWith(_basmalahUthmani)) {
    final remainder = clean.substring(_basmalahUthmani.length).trim();
    return remainder.isNotEmpty ? remainder : clean;
  }
  if (clean.startsWith(_basmalahPlain)) {
    final remainder = clean.substring(_basmalahPlain.length).trim();
    return remainder.isNotEmpty ? remainder : clean;
  }
  return clean;
}
