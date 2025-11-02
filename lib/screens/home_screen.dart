import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/prospect.dart';
import '../services/storage_service.dart';
import 'form_screen.dart';
import 'prospect_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Prospect> _todaysProspects = [];
  List<Prospect> _previousProspects = [];
  List<Prospect> _filteredTodaysProspects = [];
  List<Prospect> _filteredPreviousProspects = [];
  bool _isLoading = true;
  String? _selectedProspectId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProspects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProspects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final todaysProspects = await StorageService.getTodaysProspects();
      final previousProspects = await StorageService.getPreviousProspects();

      setState(() {
        _todaysProspects = todaysProspects;
        _previousProspects = previousProspects;
        _filteredTodaysProspects = todaysProspects;
        _filteredPreviousProspects = previousProspects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showAlert('Error', 'Failed to load prospects: $e');
    }
  }

  // Remove the _checkForCurrentForm and _showResumeFormDialog methods entirely

  void _searchProspects(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTodaysProspects = _todaysProspects;
        _filteredPreviousProspects = _previousProspects;
      } else {
        _filteredTodaysProspects = _todaysProspects
            .where(
              (prospect) =>
                  prospect.fullName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
        _filteredPreviousProspects = _previousProspects
            .where(
              (prospect) =>
                  prospect.fullName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _navigateToForm([Prospect? prospect]) {
    Navigator.of(context)
        .push(
          CupertinoPageRoute(
            builder: (context) => FormScreen(prospect: prospect),
          ),
        )
        .then((_) => _loadProspects());
  }

  void _navigateToDetail(Prospect prospect) {
    Navigator.of(context)
        .push(
          CupertinoPageRoute(
            builder: (context) => ProspectDetailScreen(prospect: prospect),
          ),
        )
        .then((_) => _loadProspects());
  }

  void _confirmDelete(Prospect prospect) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Prospect'),
        content: Text('Are you sure you want to delete ${prospect.fullName}?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await StorageService.deleteProspect(prospect.id);
                _loadProspects();
                _showAlert('Success', 'Prospect deleted successfully');
              } catch (e) {
                _showAlert('Error', 'Failed to delete prospect: $e');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_selectedProspectId != null) {
          setState(() {
            _selectedProspectId = null;
          });
        }
      },
      child: CupertinoPageScaffold(
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome Grace,',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'MontserratLight',
                                  color: Color.fromRGBO(64, 64, 64, 1),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Check out the list of clients you onboarded',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'MontserratLight',
                                  color: Color.fromRGBO(42, 42, 42, 1),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 202, 217, 239),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                CupertinoIcons.bell_solid,
                                size: 27,
                                color: Color.fromARGB(255, 35, 41, 71),
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _tabController.index = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 0,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _tabController.index == 0
                                    ? const Color.fromARGB(255, 59, 69, 119)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            "Today's clients",
                            style: TextStyle(
                              fontFamily: 'MontserratRegular',
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: _tabController.index == 0
                                  ? const Color.fromARGB(255, 59, 69, 119)
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _tabController.index = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 0,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _tabController.index == 1
                                    ? const Color.fromARGB(255, 59, 69, 119)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'Previous list',
                            style: TextStyle(
                              fontFamily: 'MontserratRegular',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _tabController.index == 1
                                  ? const Color.fromARGB(255, 59, 69, 119)
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: CupertinoTextField(
                        controller: _searchController,
                        placeholder: 'Search for a client',
                        placeholderStyle: const TextStyle(
                          fontFamily: 'MontserratRegular',
                          fontWeight: FontWeight.w400,
                          color: CupertinoColors.systemGrey2,
                        ),
                        style: const TextStyle(
                          fontFamily: 'MontserratLight',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const BoxDecoration(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 20, right: 5),
                          child: Icon(
                            CupertinoIcons.search,
                            color: CupertinoColors.systemGrey2,
                            size: 24,
                          ),
                        ),
                        onChanged: _searchProspects,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CupertinoActivityIndicator())
                        : _buildProspectsList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: const Color.fromARGB(255, 59, 69, 119),
                        borderRadius: BorderRadius.circular(30),
                        child: const Text(
                          'Add a new customer',
                          style: TextStyle(
                            fontFamily: 'MontserratRegular',
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                        onPressed: () => _navigateToForm(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProspectsList() {
    final prospects = _tabController.index == 0
        ? _filteredTodaysProspects
        : _filteredPreviousProspects;

    if (prospects.isEmpty) {
      return _buildEmptyState();
    }

    // Sort prospects in descending order (latest first)
    final sortedProspects = List<Prospect>.from(prospects)
      ..sort((a, b) => b.onboardedDate.compareTo(a.onboardedDate));

    // Group prospects by date
    final groupedProspects = <String, List<Prospect>>{};
    for (final prospect in sortedProspects) {
      final dateKey = _getDateLabel(prospect.onboardedDate);
      if (!groupedProspects.containsKey(dateKey)) {
        groupedProspects[dateKey] = [];
      }
      groupedProspects[dateKey]!.add(prospect);
    }

    return ListView(
      children: groupedProspects.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'MontserratRegular',
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(64, 64, 64, 1),
                ),
              ),
            ),
            ...entry.value.map((prospect) => _buildProspectCard(prospect)),
          ],
        );
      }).toList(),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final prospectDate = DateTime(date.year, date.month, date.day);

    if (prospectDate == today) {
      return 'Today';
    } else if (prospectDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        SizedBox(
          width: 300,
          height: 300,
          child: Image.asset(
            'images/no_data.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 400,
          child: Text(
            _tabController.index == 0
                ? 'You have not onboarded a client today. Try adding a new client to update your list.'
                : 'No previous clients found.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w700,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProspectCard(Prospect prospect) {
    final showOptions = _selectedProspectId == prospect.id;

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _selectedProspectId = prospect.id;
        });
      },
      onTap: () {
        if (showOptions) {
          setState(() {
            _selectedProspectId = null;
          });
        } else {
          if (prospect.isComplete) {
            _navigateToDetail(prospect);
          } else {
            _navigateToForm(prospect);
          }
        }
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed:
                  null, // Disable the button since we're using GestureDetector
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: prospect.selfiePath != null
                          ? FileImage(File(prospect.selfiePath!))
                          : null,
                      child: prospect.selfiePath == null
                          ? const Icon(CupertinoIcons.person)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  prospect.fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'MontserratLight',
                                    fontWeight: FontWeight.w400,
                                    color: CupertinoColors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: prospect.isComplete
                                      ? CupertinoColors.systemGreen.withOpacity(
                                          0.1,
                                        )
                                      : CupertinoColors.systemGrey.withOpacity(
                                          0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  prospect.isComplete
                                      ? 'Complete'
                                      : 'Incomplete',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'MontserratRegular',
                                    fontWeight: FontWeight.w700,
                                    color: prospect.isComplete
                                        ? const Color.fromARGB(255, 41, 131, 64)
                                        : const Color.fromARGB(255, 120, 120, 120),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Onboarded on: ${DateFormat('dd/MM/yyyy').format(prospect.onboardedDate)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'MontserratRegular',
                              fontWeight: FontWeight.w300,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Custom Options Box
          if (showOptions)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!prospect.isComplete)
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedProspectId = null;
                          });
                          _navigateToForm(prospect);
                        },
                        minimumSize: Size(0, 0),
                        child: const Row(
                          children: [
                            Icon(
                              CupertinoIcons.pencil,
                              size: 16,
                              color: Color.fromARGB(255, 59, 69, 119),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'MontserratLight',
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedProspectId = null;
                        });
                        _confirmDelete(prospect);
                      },
                      minimumSize: Size(0, 0),
                      child: const Row(
                        children: [
                          Icon(
                            CupertinoIcons.delete,
                            size: 16,
                            color: CupertinoColors.systemRed,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'MontserratLight',
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
