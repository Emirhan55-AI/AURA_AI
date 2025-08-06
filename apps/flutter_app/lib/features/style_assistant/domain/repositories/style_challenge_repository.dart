import '../models/style_challenge_new.dart';
import '../models/challenge_submission.dart';

/// Repository interface for managing style challenges
abstract class StyleChallengeRepository {
  /// Get all active challenges
  Future<List<StyleChallenge>> getActiveChallenges();
  
  /// Get all upcoming challenges
  Future<List<StyleChallenge>> getUpcomingChallenges();
  
  /// Get all past challenges
  Future<List<StyleChallenge>> getPastChallenges();
  
  /// Get challenge by ID
  Future<StyleChallenge?> getChallengeById(String challengeId);
  
  /// Join a challenge
  Future<void> joinChallenge(String challengeId);
  
  /// Leave a challenge
  Future<void> leaveChallenge(String challengeId);
  
  /// Submit an outfit to a challenge
  Future<void> submitOutfit(String challengeId, String outfitId);
  
  /// Vote on a challenge submission
  Future<void> voteOnSubmission(String challengeId, String submissionId);
  
  /// Get user's participation status in a challenge
  Future<bool> isUserParticipating(String challengeId);
  
  /// Search challenges by keyword
  Future<List<StyleChallenge>> searchChallenges(String query);
  
  /// Get trending challenges
  Future<List<StyleChallenge>> getTrendingChallenges();
  
  /// Get challenge submissions
  Future<List<ChallengeSubmission>> getChallengeSubmissions(String challengeId);
  
  /// Get user's submission for a challenge
  Future<ChallengeSubmission?> getUserSubmission(String challengeId, String userId);
  
  /// Submit entry to challenge
  Future<ChallengeSubmission> submitChallengeEntry(String challengeId, String outfitId, String description);
  
  /// Get submission by ID
  Future<ChallengeSubmission?> getSubmissionById(String submissionId);

  /// Vote for a submission
  Future<void> voteForSubmission(String submissionId);

  /// Remove vote from a submission
  Future<void> removeVote(String submissionId);
}

/// Mock implementation of StyleChallengeRepository for development
class MockStyleChallengeRepository implements StyleChallengeRepository {
  // Mock data cache
  static final List<StyleChallenge> _allChallenges = _generateMockChallenges();
  static final Set<String> _userParticipations = {'challenge1', 'challenge3'};

  @override
  Future<List<StyleChallenge>> getActiveChallenges() async {
    await _simulateNetworkDelay();
    return _allChallenges
        .where((c) => c.status == ChallengeStatus.active)
        .toList();
  }

  @override
  Future<List<StyleChallenge>> getUpcomingChallenges() async {
    await _simulateNetworkDelay();
    return _allChallenges
        .where((c) => c.status == ChallengeStatus.upcoming)
        .toList();
  }

  @override
  Future<List<StyleChallenge>> getPastChallenges() async {
    await _simulateNetworkDelay();
    return _allChallenges
        .where((c) => c.status == ChallengeStatus.past)
        .toList();
  }

  @override
  Future<StyleChallenge?> getChallengeById(String challengeId) async {
    await _simulateNetworkDelay();
    try {
      return _allChallenges.firstWhere((c) => c.id == challengeId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> joinChallenge(String challengeId) async {
    await _simulateNetworkDelay();
    _userParticipations.add(challengeId);
    
    // Update the challenge in the cache
    final challengeIndex = _allChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1) {
      final challenge = _allChallenges[challengeIndex];
      _allChallenges[challengeIndex] = challenge.copyWith(
        isParticipating: true,
        participantCount: challenge.participantCount + 1,
      );
    }
  }

  @override
  Future<void> leaveChallenge(String challengeId) async {
    await _simulateNetworkDelay();
    _userParticipations.remove(challengeId);
    
    // Update the challenge in the cache
    final challengeIndex = _allChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1) {
      final challenge = _allChallenges[challengeIndex];
      _allChallenges[challengeIndex] = challenge.copyWith(
        isParticipating: false,
        participantCount: (challenge.participantCount - 1).clamp(0, double.infinity).toInt(),
      );
    }
  }

  @override
  Future<void> submitOutfit(String challengeId, String outfitId) async {
    await _simulateNetworkDelay();
    
    // Update submission count
    final challengeIndex = _allChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1) {
      final challenge = _allChallenges[challengeIndex];
      _allChallenges[challengeIndex] = challenge.copyWith(
        submissionCount: challenge.submissionCount + 1,
      );
    }
  }

  @override
  Future<bool> isUserParticipating(String challengeId) async {
    await _simulateNetworkDelay();
    return _userParticipations.contains(challengeId);
  }

  @override
  Future<List<StyleChallenge>> searchChallenges(String query) async {
    await _simulateNetworkDelay();
    
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return _allChallenges.where((challenge) {
      return challenge.title.toLowerCase().contains(lowercaseQuery) ||
             challenge.description.toLowerCase().contains(lowercaseQuery) ||
             challenge.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  @override
  Future<List<StyleChallenge>> getTrendingChallenges() async {
    await _simulateNetworkDelay();
    
    // Return challenges sorted by participation count
    final trendingChallenges = List<StyleChallenge>.from(_allChallenges);
    trendingChallenges.sort((a, b) => b.participantCount.compareTo(a.participantCount));
    return trendingChallenges.take(5).toList();
  }

  /// Simulate network delay for realistic testing
  Future<void> _simulateNetworkDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  /// Generate comprehensive mock data for all challenge types
  static List<StyleChallenge> _generateMockChallenges() {
    final now = DateTime.now();
    
    return [
      // Active Challenges
      StyleChallenge(
        id: 'challenge1',
        title: 'Summer Beach Party Vibes',
        description: 'Create the perfect outfit for a beach party that\'s both stylish and comfortable. Think flowing fabrics, bright colors, and resort-ready accessories!',
        startTime: now.subtract(const Duration(days: 3)),
        votingStartTime: now.add(const Duration(days: 4)),
        endTime: now.add(const Duration(days: 7)),
        status: ChallengeStatus.active,
        prizeDescription: 'Featured spotlight on app homepage + \$100 summer shopping voucher',
        difficulty: ChallengeDifficulty.beginner,
        imageUrl: 'https://images.unsplash.com/photo-1544966503-7cc5ac882d5d',
        tags: ['summer', 'beach', 'casual', 'colorful'],
        submissionCount: 23,
        participantCount: 156,
        isParticipating: true,
        prizeValue: 100,
        sponsorName: 'Summer Style Co.',
      ),
      
      StyleChallenge(
        id: 'challenge2',
        title: 'Office Chic on a Budget',
        description: 'Create a professional office look using affordable pieces under \$200 total. Prove that style doesn\'t have to break the bank!',
        startTime: now.subtract(const Duration(days: 1)),
        votingStartTime: now.add(const Duration(days: 6)),
        endTime: now.add(const Duration(days: 9)),
        status: ChallengeStatus.active,
        prizeDescription: '300 Style Points + feature in "Budget Finds" collection',
        difficulty: ChallengeDifficulty.intermediate,
        imageUrl: 'https://images.unsplash.com/photo-1580566232691-a497d124276c',
        tags: ['professional', 'budget', 'office', 'affordable'],
        submissionCount: 31,
        participantCount: 204,
        isParticipating: false,
        prizeValue: 50,
      ),

      // Upcoming Challenges
      StyleChallenge(
        id: 'challenge3',
        title: 'Autumn Festival Fashion',
        description: 'Design the perfect outfit for autumn festivals - think layers, warm colors, and cozy textures that still look festival-ready!',
        startTime: now.add(const Duration(days: 5)),
        votingStartTime: now.add(const Duration(days: 12)),
        endTime: now.add(const Duration(days: 15)),
        status: ChallengeStatus.upcoming,
        prizeDescription: 'Autumn wardrobe makeover worth \$500',
        difficulty: ChallengeDifficulty.intermediate,
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        tags: ['autumn', 'festival', 'layers', 'cozy'],
        submissionCount: 0,
        participantCount: 89,
        isParticipating: true,
        prizeValue: 500,
        sponsorName: 'Autumn Vibes',
      ),

      StyleChallenge(
        id: 'challenge4',
        title: 'Sustainable Fashion Challenge',
        description: 'Create stunning outfits using only sustainable and eco-friendly fashion pieces. Show the world that conscious fashion is beautiful!',
        startTime: now.add(const Duration(days: 7)),
        votingStartTime: now.add(const Duration(days: 14)),
        endTime: now.add(const Duration(days: 17)),
        status: ChallengeStatus.upcoming,
        prizeDescription: 'Eco-friendly wardrobe bundle + sustainability certification',
        difficulty: ChallengeDifficulty.advanced,
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64',
        tags: ['sustainable', 'eco-friendly', 'conscious', 'green'],
        submissionCount: 0,
        participantCount: 67,
        isParticipating: false,
        prizeValue: 300,
        sponsorName: 'EcoFashion Hub',
      ),

      // Past Challenges
      StyleChallenge(
        id: 'challenge5',
        title: 'Date Night Glam',
        description: 'Create the perfect romantic date night outfit that makes you feel confident and beautiful.',
        startTime: now.subtract(const Duration(days: 20)),
        votingStartTime: now.subtract(const Duration(days: 13)),
        endTime: now.subtract(const Duration(days: 10)),
        status: ChallengeStatus.past,
        prizeDescription: 'Gift card to premium boutique worth \$200',
        difficulty: ChallengeDifficulty.beginner,
        imageUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446',
        tags: ['date-night', 'romantic', 'elegant', 'evening'],
        submissionCount: 45,
        participantCount: 234,
        isParticipating: true,
        prizeValue: 200,
        winnerId: 'user_123',
      ),

      StyleChallenge(
        id: 'challenge6',
        title: 'Streetwear Supreme',
        description: 'Show off your streetwear style with the latest urban fashion trends. Mix high and low, vintage and modern!',
        startTime: now.subtract(const Duration(days: 35)),
        votingStartTime: now.subtract(const Duration(days: 28)),
        endTime: now.subtract(const Duration(days: 25)),
        status: ChallengeStatus.past,
        prizeDescription: 'Limited edition streetwear collection',
        difficulty: ChallengeDifficulty.advanced,
        imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f',
        tags: ['streetwear', 'urban', 'trendy', 'edgy'],
        submissionCount: 67,
        participantCount: 389,
        isParticipating: false,
        prizeValue: 400,
        winnerId: 'user_456',
      ),

      // Voting Phase Challenges
      StyleChallenge(
        id: 'challenge7',
        title: 'Minimalist Monday',
        description: 'Create a capsule wardrobe look with 5 pieces or less. Prove that less is more in fashion!',
        startTime: now.subtract(const Duration(days: 8)),
        votingStartTime: now.subtract(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 2)),
        status: ChallengeStatus.voting,
        prizeDescription: 'Quality minimalist wardrobe essentials',
        difficulty: ChallengeDifficulty.intermediate,
        imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d',
        tags: ['minimalist', 'capsule', 'simple', 'essential'],
        submissionCount: 52,
        participantCount: 178,
        isParticipating: false,
        isVotingOpen: true,
        prizeValue: 350,
      ),
    ];
  }

  // Mock submission data cache
  static final List<ChallengeSubmission> _allSubmissions = _generateMockSubmissions();
  static final Map<String, Set<String>> _userVotes = {};

  @override
  Future<List<ChallengeSubmission>> getChallengeSubmissions(String challengeId) async {
    await _simulateNetworkDelay();
    return _allSubmissions
        .where((s) => s.challengeId == challengeId)
        .toList()
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
  }

  @override
  Future<ChallengeSubmission?> getUserSubmission(String challengeId, String userId) async {
    await _simulateNetworkDelay();
    try {
      return _allSubmissions.firstWhere(
        (s) => s.challengeId == challengeId && s.userId == userId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ChallengeSubmission> submitChallengeEntry(String challengeId, String outfitId, String description) async {
    await _simulateNetworkDelay();
    
    final submission = ChallengeSubmission(
      id: 'submission_${DateTime.now().millisecondsSinceEpoch}',
      challengeId: challengeId,
      combinationId: outfitId,
      userId: 'current_user',
      userName: 'You',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
      voteCount: 0,
      status: SubmissionStatus.pending,
      submissionTime: DateTime.now(),
      outfitImageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050',
      description: description,
      tags: ['outfit', 'challenge'],
      hasUserVoted: false,
      rank: 0,
      score: 0.0,
    );
    
    _allSubmissions.add(submission);
    return submission;
  }

  @override
  Future<void> voteOnSubmission(String challengeId, String submissionId) async {
    await _simulateNetworkDelay();
    
    final userVotesForChallenge = _userVotes.putIfAbsent(challengeId, () => <String>{});
    if (userVotesForChallenge.contains(submissionId)) {
      throw Exception('User has already voted on this submission');
    }
    
    userVotesForChallenge.add(submissionId);
    
    // Update vote count in submission
    final submissionIndex = _allSubmissions.indexWhere((s) => s.id == submissionId);
    if (submissionIndex != -1) {
      final submission = _allSubmissions[submissionIndex];
      _allSubmissions[submissionIndex] = submission.copyWith(
        voteCount: submission.voteCount + 1,
        hasUserVoted: true,
      );
    }
  }

  @override
  Future<ChallengeSubmission?> getSubmissionById(String submissionId) async {
    await _simulateNetworkDelay();
    try {
      return _allSubmissions.firstWhere((s) => s.id == submissionId);
    } catch (_) {
      return null;
    }
  }

  /// Generate mock submissions data
  static List<ChallengeSubmission> _generateMockSubmissions() {
    final now = DateTime.now();
    
    return [
      ChallengeSubmission(
        id: 'sub1',
        challengeId: 'challenge1',
        combinationId: 'outfit1',
        userId: 'user1',
        userName: 'Emma Fashion',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
        voteCount: 45,
        status: SubmissionStatus.approved,
        submissionTime: now.subtract(const Duration(hours: 6)),
        outfitImageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050',
        description: 'Elegant summer vibes with sustainable fabrics',
        tags: ['sustainable', 'summer', 'elegant'],
        hasUserVoted: false,
        rank: 1,
        score: 4.8,
      ),
      ChallengeSubmission(
        id: 'sub2',
        challengeId: 'challenge1',
        combinationId: 'outfit2',
        userId: 'user2',
        userName: 'StyleGuru',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=2',
        voteCount: 38,
        status: SubmissionStatus.approved,
        submissionTime: now.subtract(const Duration(hours: 4)),
        outfitImageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d',
        description: 'Minimalist approach to summer fashion',
        tags: ['minimalist', 'chic'],
        hasUserVoted: false,
        rank: 2,
        score: 4.6,
      ),
      ChallengeSubmission(
        id: 'sub3',
        challengeId: 'challenge1',
        combinationId: 'outfit3',
        userId: 'user3',
        userName: 'TrendSetter',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=3',
        voteCount: 29,
        status: SubmissionStatus.approved,
        submissionTime: now.subtract(const Duration(hours: 2)),
        outfitImageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae',
        description: 'Bold colors meet sustainable choices',
        tags: ['bold', 'colorful', 'sustainable'],
        hasUserVoted: false,
        rank: 3,
        score: 4.3,
      ),
      ChallengeSubmission(
        id: 'sub4',
        challengeId: 'challenge7',
        combinationId: 'outfit4',
        userId: 'user4',
        userName: 'MinimalMaven',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=4',
        voteCount: 67,
        status: SubmissionStatus.approved,
        submissionTime: now.subtract(const Duration(days: 2)),
        outfitImageUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446',
        description: 'Perfect capsule wardrobe essentials',
        tags: ['capsule', 'essentials', 'timeless'],
        hasUserVoted: true,
        rank: 1,
        score: 4.9,
      ),
    ];
  }

  @override
  Future<void> voteForSubmission(String submissionId) async {
    await _simulateNetworkDelay();
    // In real implementation, this would call API to register vote
    // For mock, we just simulate the action
  }

  @override
  Future<void> removeVote(String submissionId) async {
    await _simulateNetworkDelay();
    // In real implementation, this would call API to remove vote
    // For mock, we just simulate the action
  }
}
