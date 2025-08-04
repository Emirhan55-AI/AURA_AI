import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/post_detail/models.dart';

/// Social Post Detail Controller State
/// 
/// Manages the complete state of a single social post detail including
/// the post data, comments, loading states, and user interactions.
class SocialPostDetailState {
  final AsyncValue<SocialPostDetail?> postDetail;
  final AsyncValue<List<Comment>> comments;
  final bool isSubmittingComment;
  final String? currentPostId;

  const SocialPostDetailState({
    required this.postDetail,
    required this.comments,
    this.isSubmittingComment = false,
    this.currentPostId,
  });

  /// Creates initial state for a specific post ID
  factory SocialPostDetailState.initial({String? postId}) {
    return SocialPostDetailState(
      postDetail: const AsyncValue.loading(),
      comments: const AsyncValue.loading(),
      isSubmittingComment: false,
      currentPostId: postId,
    );
  }

  /// Creates a copy of the state with updated values
  SocialPostDetailState copyWith({
    AsyncValue<SocialPostDetail?>? postDetail,
    AsyncValue<List<Comment>>? comments,
    bool? isSubmittingComment,
    String? currentPostId,
  }) {
    return SocialPostDetailState(
      postDetail: postDetail ?? this.postDetail,
      comments: comments ?? this.comments,
      isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
      currentPostId: currentPostId ?? this.currentPostId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocialPostDetailState &&
        other.postDetail == postDetail &&
        other.comments == comments &&
        other.isSubmittingComment == isSubmittingComment &&
        other.currentPostId == currentPostId;
  }

  @override
  int get hashCode {
    return Object.hash(
      postDetail,
      comments,
      isSubmittingComment,
      currentPostId,
    );
  }
}

/// Social Post Detail Controller
/// 
/// Manages the state and business logic for the social post detail screen.
/// Handles loading post details, managing comments, likes, saves, and other interactions.
class SocialPostDetailController extends StateNotifier<SocialPostDetailState> {
  final String postId;

  SocialPostDetailController(this.postId) 
      : super(SocialPostDetailState.initial(postId: postId)) {
    // Auto-load post data when controller is created
    loadPostDetail();
    loadComments();
  }

  /// Loads the detailed information for the current post
  /// 
  /// Fetches the post data and updates the state with either
  /// the loaded post or an error state.
  Future<void> loadPostDetail() async {
    try {
      state = state.copyWith(postDetail: const AsyncValue.loading());
      
      // Simulate API call - replace with actual service call
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final postDetail = SocialPostDetail.getSample();
      
      state = state.copyWith(postDetail: AsyncValue.data(postDetail));
    } catch (error, stackTrace) {
      state = state.copyWith(
        postDetail: AsyncValue<SocialPostDetail?>.error(error, stackTrace),
      );
    }
  }

  /// Loads comments for the current post
  /// 
  /// Fetches the comments list and updates the state.
  Future<void> loadComments() async {
    try {
      state = state.copyWith(comments: const AsyncValue.loading());
      
      // Simulate API call - replace with actual service call
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final comments = Comment.getSampleComments();
      
      state = state.copyWith(comments: AsyncValue.data(comments));
    } catch (error, stackTrace) {
      state = state.copyWith(
        comments: AsyncValue<List<Comment>>.error(error, stackTrace),
      );
    }
  }

  /// Toggles the like status of the current post
  /// 
  /// Updates both the local state and sends the change to the backend.
  /// Optimistically updates the UI before the API call completes.
  Future<void> togglePostLike() async {
    final currentPostDetail = state.postDetail.valueOrNull;
    if (currentPostDetail == null) return;

    try {
      // Optimistic update
      final updatedPostDetail = currentPostDetail.copyWith(
        likeCount: currentPostDetail.isLikedByCurrentUser
            ? currentPostDetail.likeCount - 1
            : currentPostDetail.likeCount + 1,
        isLikedByCurrentUser: !currentPostDetail.isLikedByCurrentUser,
      );

      state = state.copyWith(
        postDetail: AsyncValue.data(updatedPostDetail),
      );

      // Simulate API call - replace with actual service call
      await Future<void>.delayed(const Duration(milliseconds: 200));
      
      // In a real app, you would make an API call here
      // await socialService.togglePostLike(postId);
      
    } catch (error, stackTrace) {
      // Revert optimistic update on error
      state = state.copyWith(
        postDetail: AsyncValue.data(currentPostDetail),
      );
      
      // Handle error - could show a snackbar or toast
      rethrow;
    }
  }

  /// Toggles the save status of the current post
  /// 
  /// Updates both the local state and sends the change to the backend.
  /// Optimistically updates the UI before the API call completes.
  Future<void> togglePostSave() async {
    final currentPostDetail = state.postDetail.valueOrNull;
    if (currentPostDetail == null) return;

    try {
      // Optimistic update
      final updatedPostDetail = currentPostDetail.copyWith(
        isSavedByCurrentUser: !currentPostDetail.isSavedByCurrentUser,
      );

      state = state.copyWith(
        postDetail: AsyncValue.data(updatedPostDetail),
      );

      // Simulate API call - replace with actual service call
      await Future<void>.delayed(const Duration(milliseconds: 200));
      
      // In a real app, you would make an API call here
      // await socialService.togglePostSave(postId);
      
    } catch (error, stackTrace) {
      // Revert optimistic update on error
      state = state.copyWith(
        postDetail: AsyncValue.data(currentPostDetail),
      );
      
      // Handle error - could show a snackbar or toast
      rethrow;
    }
  }

  /// Toggles the like status of a specific comment
  /// 
  /// Updates the comment's like status and count in the local state.
  /// Optimistically updates the UI before the API call completes.
  Future<void> toggleCommentLike(String commentId) async {
    final currentComments = state.comments.valueOrNull;
    if (currentComments == null) return;

    try {
      // Find and update the specific comment
      final updatedComments = currentComments.map((comment) {
        if (comment.id == commentId) {
          return comment.copyWith(
            likeCount: comment.isLikedByCurrentUser
                ? comment.likeCount - 1
                : comment.likeCount + 1,
            isLikedByCurrentUser: !comment.isLikedByCurrentUser,
          );
        }
        return comment;
      }).toList();

      state = state.copyWith(
        comments: AsyncValue.data(updatedComments),
      );

      // Simulate API call - replace with actual service call
      await Future<void>.delayed(const Duration(milliseconds: 150));
      
      // In a real app, you would make an API call here
      // await socialService.toggleCommentLike(commentId);
      
    } catch (error, stackTrace) {
      // Revert optimistic update on error
      state = state.copyWith(
        comments: AsyncValue.data(currentComments),
      );
      
      // Handle error - could show a snackbar or toast
      rethrow;
    }
  }

  /// Adds a new comment to the current post
  /// 
  /// Creates a new comment with the provided content and adds it to the
  /// comments list. Also updates the post's comment count.
  Future<void> addComment(String content) async {
    if (content.trim().isEmpty) return;

    final currentComments = state.comments.valueOrNull ?? <Comment>[];
    final currentPostDetail = state.postDetail.valueOrNull;

    try {
      // Set submitting state
      state = state.copyWith(isSubmittingComment: true);

      // Create new comment
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: "current_user", // Replace with actual user ID
        authorDisplayName: "Current User", // Replace with actual user name
        authorAvatarUrl: "https://via.placeholder.com/40", // Replace with actual user avatar
        text: content,
        timestamp: DateTime.now(),
        likeCount: 0,
        isLikedByCurrentUser: false,
      );

      // Add comment optimistically
      final updatedComments = [newComment, ...currentComments];
      
      // Update comments state
      state = state.copyWith(
        comments: AsyncValue.data(updatedComments),
        isSubmittingComment: false,
      );

      // Update post detail comment count if available
      if (currentPostDetail != null) {
        final updatedPostDetail = currentPostDetail.copyWith(
          commentCount: currentPostDetail.commentCount + 1,
          comments: updatedComments,
        );

        state = state.copyWith(
          postDetail: AsyncValue.data(updatedPostDetail),
        );
      }

      // Simulate API call - replace with actual service call
      await Future<void>.delayed(const Duration(milliseconds: 300));
      
      // In a real app, you would make an API call here
      // await socialService.addComment(postId, content);
      
    } catch (error, stackTrace) {
      // Revert optimistic updates on error
      state = state.copyWith(
        comments: AsyncValue<List<Comment>>.error(error, stackTrace),
        isSubmittingComment: false,
      );
      
      // Handle error - could show a snackbar or toast
      rethrow;
    }
  }

  /// Refreshes both post detail and comments data
  /// 
  /// Useful for pull-to-refresh functionality.
  Future<void> refresh() async {
    await Future.wait([
      loadPostDetail(),
      loadComments(),
    ]);
  }

  /// Shares the current post
  /// 
  /// Handles the share functionality and updates share count.
  Future<void> sharePost() async {
    final currentPostDetail = state.postDetail.valueOrNull;
    if (currentPostDetail == null) return;

    try {
      // In a real app, you would implement actual sharing logic here
      // await shareService.sharePost(currentPostDetail);
      
      // Simulate API call to update share count
      await Future<void>.delayed(const Duration(milliseconds: 100));
      
    } catch (error, stackTrace) {
      // Handle error - could show a snackbar or toast
      rethrow;
    }
  }
}

/// Provider for Social Post Detail Controller
/// Uses StateNotifierProvider.family to create a controller instance for each post ID
final socialPostDetailControllerProvider = StateNotifierProvider.family<SocialPostDetailController, SocialPostDetailState, String>(
  (ref, postId) => SocialPostDetailController(postId),
);
