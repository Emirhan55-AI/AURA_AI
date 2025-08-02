import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  // Common strings
  @override
  String get appName => 'Aura';
  @override
  String get close => 'Close';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get save => 'Save';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get add => 'Add';
  @override
  String get search => 'Search';
  @override
  String get filter => 'Filter';
  @override
  String get sort => 'Sort';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get retry => 'Retry';
  @override
  String get success => 'Success';
  @override
  String get warning => 'Warning';
  @override
  String get info => 'Info';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get ok => 'OK';
  @override
  String get back => 'Back';
  @override
  String get next => 'Next';
  @override
  String get previous => 'Previous';
  @override
  String get done => 'Done';
  @override
  String get skip => 'Skip';
  @override
  String get selectAll => 'Select All';
  @override
  String get deselectAll => 'Deselect All';
  @override
  String get noDataFound => 'No data found';
  @override
  String get noResultsFound => 'No results found';
  @override
  String get tryAgain => 'Try again';
  @override
  String get refresh => 'Refresh';

  // Authentication
  @override
  String get welcome => 'Welcome';
  @override
  String get login => 'Login';
  @override
  String get logout => 'Logout';
  @override
  String get register => 'Register';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get resetPassword => 'Reset Password';
  @override
  String get createAccount => 'Create Account';
  @override
  String get alreadyHaveAccount => 'Already have an account?';
  @override
  String get dontHaveAccount => "Don't have an account?";
  @override
  String get invalidEmail => 'Please enter a valid email';
  @override
  String get invalidPassword => 'Password must be at least 6 characters';
  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
  @override
  String get loginFailed => 'Login failed. Please try again.';
  @override
  String get registrationFailed => 'Registration failed. Please try again.';
  @override
  String get resetPasswordSent => 'Password reset email sent';

  // Onboarding
  @override
  String get onboardingTitle1 => 'Organize Your Wardrobe';
  @override
  String get onboardingDescription1 => 'Keep track of all your clothing items in one place';
  @override
  String get onboardingTitle2 => 'Create Amazing Outfits';
  @override
  String get onboardingDescription2 => 'Mix and match your items to create perfect outfits';
  @override
  String get onboardingTitle3 => 'Smart Recommendations';
  @override
  String get onboardingDescription3 => 'Get personalized outfit suggestions based on weather and occasions';
  @override
  String get getStarted => 'Get Started';

  // Wardrobe
  @override
  String get wardrobe => 'Wardrobe';
  @override
  String get myWardrobe => 'My Wardrobe';
  @override
  String get addClothingItem => 'Add Clothing Item';
  @override
  String get clothingItem => 'Clothing Item';
  @override
  String get clothingItems => 'Clothing Items';
  @override
  String get category => 'Category';
  @override
  String get categories => 'Categories';
  @override
  String get color => 'Color';
  @override
  String get colors => 'Colors';
  @override
  String get brand => 'Brand';
  @override
  String get size => 'Size';
  @override
  String get condition => 'Condition';
  @override
  String get purchaseDate => 'Purchase Date';
  @override
  String get purchasePrice => 'Purchase Price';
  @override
  String get notes => 'Notes';
  @override
  String get favorite => 'Favorite';
  @override
  String get favorites => 'Favorites';
  @override
  String get addToFavorites => 'Add to Favorites';
  @override
  String get removeFromFavorites => 'Remove from Favorites';
  @override
  String get selectPhoto => 'Select Photo';
  @override
  String get takePhoto => 'Take Photo';
  @override
  String get chooseFromGallery => 'Choose from Gallery';
  @override
  String get itemAddedSuccessfully => 'Item added successfully';
  @override
  String get itemUpdatedSuccessfully => 'Item updated successfully';
  @override
  String get itemDeletedSuccessfully => 'Item deleted successfully';
  @override
  String get deleteItemConfirmation => 'Are you sure you want to delete this item?';
  @override
  String get deleteItem => 'Delete Item';

  // Categories
  @override
  String get tops => 'Tops';
  @override
  String get bottoms => 'Bottoms';
  @override
  String get dresses => 'Dresses';
  @override
  String get outerwear => 'Outerwear';
  @override
  String get shoes => 'Shoes';
  @override
  String get accessories => 'Accessories';
  @override
  String get underwear => 'Underwear';
  @override
  String get sleepwear => 'Sleepwear';
  @override
  String get activewear => 'Activewear';
  @override
  String get formal => 'Formal';
  @override
  String get casual => 'Casual';
  @override
  String get work => 'Work';

  // Colors
  @override
  String get black => 'Black';
  @override
  String get white => 'White';
  @override
  String get gray => 'Gray';
  @override
  String get brown => 'Brown';
  @override
  String get beige => 'Beige';
  @override
  String get red => 'Red';
  @override
  String get pink => 'Pink';
  @override
  String get orange => 'Orange';
  @override
  String get yellow => 'Yellow';
  @override
  String get green => 'Green';
  @override
  String get blue => 'Blue';
  @override
  String get purple => 'Purple';
  @override
  String get navy => 'Navy';
  @override
  String get multicolor => 'Multicolor';

  // Conditions
  @override
  String get excellent => 'Excellent';
  @override
  String get good => 'Good';
  @override
  String get fair => 'Fair';
  @override
  String get poor => 'Poor';

  // Outfits
  @override
  String get outfits => 'Outfits';
  @override
  String get myOutfits => 'My Outfits';
  @override
  String get createOutfit => 'Create Outfit';
  @override
  String get outfitName => 'Outfit Name';
  @override
  String get outfitCreated => 'Outfit created successfully';
  @override
  String get outfitUpdated => 'Outfit updated successfully';
  @override
  String get outfitDeleted => 'Outfit deleted successfully';
  @override
  String get deleteOutfitConfirmation => 'Are you sure you want to delete this outfit?';
  @override
  String get selectItems => 'Select Items';
  @override
  String get noItemsSelected => 'No items selected';
  @override
  String get outfit => 'Outfit';

  // Settings
  @override
  String get settings => 'Settings';
  @override
  String get profile => 'Profile';
  @override
  String get preferences => 'Preferences';
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get darkMode => 'Dark Mode';
  @override
  String get lightMode => 'Light Mode';
  @override
  String get systemMode => 'System Mode';
  @override
  String get notifications => 'Notifications';
  @override
  String get privacy => 'Privacy';
  @override
  String get about => 'About';
  @override
  String get version => 'Version';
  @override
  String get support => 'Support';
  @override
  String get contactUs => 'Contact Us';
  @override
  String get rateApp => 'Rate App';
  @override
  String get shareApp => 'Share App';
  @override
  String get clearCache => 'Clear Cache';
  @override
  String get clearData => 'Clear Data';
  @override
  String get exportData => 'Export Data';
  @override
  String get importData => 'Import Data';

  // Errors
  @override
  String get somethingWentWrong => 'Something went wrong';
  @override
  String get networkError => 'Network error';
  @override
  String get noInternetConnection => 'No internet connection';
  @override
  String get serverError => 'Server error';
  @override
  String get dataLoadingFailed => 'Failed to load data';
  @override
  String get dataSavingFailed => 'Failed to save data';
  @override
  String get validationError => 'Please check your input';
  @override
  String get permissionDenied => 'Permission denied';
  @override
  String get fileNotFound => 'File not found';
  @override
  String get invalidFile => 'Invalid file';
  @override
  String get uploadFailed => 'Upload failed';

  // Date and Time
  @override
  String get today => 'Today';
  @override
  String get yesterday => 'Yesterday';
  @override
  String get tomorrow => 'Tomorrow';
  @override
  String get thisWeek => 'This Week';
  @override
  String get lastWeek => 'Last Week';
  @override
  String get thisMonth => 'This Month';
  @override
  String get lastMonth => 'Last Month';
  @override
  String get thisYear => 'This Year';
  @override
  String get lastYear => 'Last Year';

  // Statistics
  @override
  String get statistics => 'Statistics';
  @override
  String get totalItems => 'Total Items';
  @override
  String get totalOutfits => 'Total Outfits';
  @override
  String get favoriteItems => 'Favorite Items';
  @override
  String get recentlyAdded => 'Recently Added';
  @override
  String get mostWorn => 'Most Worn';
  @override
  String get leastWorn => 'Least Worn';
  @override
  String get averagePrice => 'Average Price';
  @override
  String get totalValue => 'Total Value';
}
