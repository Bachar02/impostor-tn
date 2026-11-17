import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// [REVIEW] Product name (glossary key app.name). Provisional spelling; variants under review: إمبوستر, أمبوستور.
  ///
  /// In ar, this message translates to:
  /// **'إمبوستور'**
  String get appName;

  /// [REVIEW] Got it. Spec key action.got_it; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'فهمت'**
  String get actionGotIt;

  /// [REVIEW] Continue. Spec key action.continue; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'كمّل'**
  String get actionContinue;

  /// [REVIEW] Add. Spec key action.add; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'زيد'**
  String get actionAdd;

  /// [REVIEW] Start voting. Spec key action.start_vote; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'نبداو التصويت'**
  String get actionStartVote;

  /// [REVIEW] See the result. Spec key action.see_result; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'شوفوا النتيجة'**
  String get actionSeeResult;

  /// [REVIEW] Vote again. Spec key action.runoff_start; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'نعاودو التصويت'**
  String get actionRunoffStart;

  /// [REVIEW] Change players or packs. Spec key action.change_setup; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'بدّل اللعّابة والباكوات'**
  String get actionChangeSetup;

  /// [REVIEW] Home. Spec key action.home; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get actionHome;

  /// [REVIEW] The last game could not be restored. Spec key state.restore_failed; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'الطرح اللي فات ما نجّمناش نرجّعوه'**
  String get stateRestoreFailed;

  /// [REVIEW] Pass the phone to (shown above the name). Spec key handoff.pass_label; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'أعطي التليفون لـ'**
  String get handoffPassLabel;

  /// [REVIEW] Role (label on the sealed ticket, above the player's name). Spec key reveal.role_label_sealed; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'دور'**
  String get revealRoleLabelSealed;

  /// [REVIEW] 12 players is the maximum. Spec key players.max_reached; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'12 لعّاب هو الحدّ'**
  String get playersMaxReached;

  /// [REVIEW] Move earlier in the order. Spec key players.move_earlier; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'قدّم'**
  String get playersMoveEarlier;

  /// [REVIEW] Move later in the order. Spec key players.move_later; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'أخّر'**
  String get playersMoveLater;

  /// [REVIEW] Choose the packs. Spec key packs.title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'اختار الباكوات'**
  String get packsTitle;

  /// [REVIEW] Choose at least one pack. Spec key error.no_pack; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'اختار باكو واحد على الأقل'**
  String get errorNoPack;

  /// [REVIEW] No word is available to play with. Spec key error.no_words; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'ما فمّا حتى كلمة تنجّموا تلعبوا بيها'**
  String get errorNoWords;

  /// [REVIEW] Fonts and icons. Spec key settings.credits; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'الخطوط والأيقونات'**
  String get settingsCredits;

  /// [REVIEW] Licences. Spec key settings.licenses; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'التراخيص'**
  String get settingsLicenses;

  /// [REVIEW] Version {v}. Spec key settings.version; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'النسخة {v}'**
  String settingsVersion(String v);

  /// [REVIEW] The goal. Spec key tutorial.goal_title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'الهدف'**
  String get tutorialGoalTitle;

  /// [REVIEW] Everyone has the same secret word except one player, the Impostor. Find them.. Spec key tutorial.goal_body; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'الكل عندهم نفس الكلمة السرّية، كان واحد: الإمبوستور. لازم تلقاوه.'**
  String get tutorialGoalBody;

  /// [REVIEW] Civilian and Impostor. Spec key tutorial.roles_title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'المدني والإمبوستور'**
  String get tutorialRolesTitle;

  /// [REVIEW] A civilian sees the word and its category. The Impostor sees the category only.. Spec key tutorial.roles_body; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'المدني يشوف الكلمة والصنف متاعها. الإمبوستور يشوف الصنف برك.'**
  String get tutorialRolesBody;

  /// [REVIEW] One phone, passed around. Spec key tutorial.handoff_title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'تليفون واحد يدور'**
  String get tutorialHandoffTitle;

  /// [REVIEW] Each player takes the phone, looks at their role alone, hides it, then passes it on.. Spec key tutorial.handoff_body; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'كل لعّاب ياخذ التليفون، يشوف دورو وحدو، يخبّيه، ومبعد يعدّيه.'**
  String get tutorialHandoffBody;

  /// [REVIEW] One-word clues. Spec key tutorial.clues_title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'تلميح بكلمة وحدة'**
  String get tutorialCluesTitle;

  /// [REVIEW] Each player says one word about the secret word. Passing is allowed.. Spec key tutorial.clues_body; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'كل واحد يقول كلمة وحدة على الكلمة السرّية. تنجّم تعدّي من غير ما تقول شي.'**
  String get tutorialCluesBody;

  /// [REVIEW] The vote. Spec key tutorial.vote_title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'التصويت'**
  String get tutorialVoteTitle;

  /// [REVIEW] Everyone votes in secret for the player they suspect; not for themselves. If the top is tied, there is one more vote between the tied players. If it is tied again, the game is a draw.. Spec key tutorial.vote_body; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'كل واحد يصوّت في السرّ على اللي يشكّ فيه، وما يصوّتش على روحو. كان فمّا تعادل، نعاودو مرّة وحدة بين المتعادلين. وكان تعاود التعادل، الطرح يوفى بتعادل.'**
  String get tutorialVoteBody;

  /// [REVIEW] The last chance. Spec key tutorial.guess_title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'آخر فرصة'**
  String get tutorialGuessTitle;

  /// [REVIEW] A caught Impostor gets one guess at the secret word: right, the Impostor wins; wrong, the civilians win. If a civilian is voted out, the Impostor wins.. Spec key tutorial.guess_body; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'كان شدّيتو الإمبوستور، عندو محاولة وحدة باش يعرف الكلمة: كان جابها يربح، وكان غلط المدنيين يربحوا. وكان خرّجتو مدني، الإمبوستور يربح.'**
  String get tutorialGuessBody;

  /// [REVIEW] Put the phone in the middle. Spec key discussion.put_phone; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'حطّوا التليفون في الوسط'**
  String get discussionPutPhone;

  /// [REVIEW] Each player says one word about the secret word. Spec key discussion.rule_one_word; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'كل واحد يقول كلمة وحدة على الكلمة السرّية'**
  String get discussionRuleOneWord;

  /// [REVIEW] Passing is allowed. Spec key discussion.rule_pass; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'تنجّم تعدّي من غير ما تقول شي'**
  String get discussionRulePass;

  /// [REVIEW] When everyone is ready, start the vote. Spec key discussion.rule_then_vote; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'وقت تكمّلوا، ابداو التصويت'**
  String get discussionRuleThenVote;

  /// [REVIEW] Who is the Impostor?. Spec key vote.title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'شكون الإمبوستور؟'**
  String get voteTitle;

  /// [REVIEW] Second vote. Spec key vote.runoff_title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'التصويت الثاني'**
  String get voteRunoffTitle;

  /// [REVIEW] Choose among the tied players. Spec key vote.runoff_hint; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'اختار من بين المتعادلين'**
  String get voteRunoffHint;

  /// [REVIEW] Vote result. Spec key tally.title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة التصويت'**
  String get tallyTitle;

  /// [REVIEW] {name} got the most votes. Spec key tally.nominated; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'أكثر أصوات: {name}'**
  String tallyNominated(String name);

  /// [REVIEW] {name} is the Impostor. Spec key tally.impostor_caught; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'الإمبوستور: {name}'**
  String tallyImpostorCaught(String name);

  /// [REVIEW] The Impostor has one last chance: a single guess at the secret word. Spec key tally.final_chance; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'آخر فرصة للإمبوستور: محاولة وحدة على الكلمة السرّية'**
  String get tallyFinalChance;

  /// [REVIEW] What is the secret word?. Spec key guess.title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'شنوّة الكلمة السرّية؟'**
  String get guessTitle;

  /// [REVIEW] One attempt only. Spec key guess.one_chance; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'محاولة وحدة برك'**
  String get guessOneChance;

  /// [REVIEW] Your answer. Spec key guess.label; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'جوابك'**
  String get guessLabel;

  /// [REVIEW] Is this your final answer?. Spec key guess.review_title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'هذا جوابك النهائي؟'**
  String get guessReviewTitle;

  /// [REVIEW] Yes, this is my answer. Spec key guess.confirm_final; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'إيه، هذا جوابي'**
  String get guessConfirmFinal;

  /// [REVIEW] Change it. Spec key guess.edit; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'نبدّلو'**
  String get guessEdit;

  /// [REVIEW] The Impostor's answer. Spec key result.guess_label; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'جواب الإمبوستور'**
  String get resultGuessLabel;

  /// [REVIEW] Correct. Spec key result.guess_correct; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'صحيح'**
  String get resultGuessCorrect;

  /// [REVIEW] Wrong. Spec key result.guess_wrong; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'غالط'**
  String get resultGuessWrong;

  /// [REVIEW] The votes. Spec key result.votes_title; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'الأصوات'**
  String get resultVotesTitle;

  /// [REVIEW] First vote. Spec key result.first_ballot; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'التصويت الأوّل'**
  String get resultFirstBallot;

  /// [REVIEW] The second vote was tied as well. Spec key result.draw_note; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'حتى التصويت الثاني وفى بتعادل'**
  String get resultDrawNote;

  /// [REVIEW] A civilian was voted out. Spec key result.civilian_out; draft from SCREEN_SPECIFICATIONS.md Appendix A, merged under D-26. Not reviewed.
  ///
  /// In ar, this message translates to:
  /// **'خرّجتو مدني'**
  String get resultCivilianOut;

  /// [REVIEW] Impostor. Glossary key role.impostor (ARABIC_LOCALIZATION.md §5). Note: Alternative: الدخيل (more MSA)
  ///
  /// In ar, this message translates to:
  /// **'إمبوستور'**
  String get roleImpostor;

  /// [REVIEW] Civilian. Glossary key role.civilian (ARABIC_LOCALIZATION.md §5). Note: Plural used: المدنيين
  ///
  /// In ar, this message translates to:
  /// **'مدني'**
  String get roleCivilian;

  /// [REVIEW] Players. Glossary key players.title (ARABIC_LOCALIZATION.md §5). Note: Singular لعّاب
  ///
  /// In ar, this message translates to:
  /// **'اللعّابة'**
  String get playersTitle;

  /// [REVIEW] Up to 16 characters. Glossary key players.name_limit (ARABIC_LOCALIZATION.md §5). Note: Limit itself must come from the PRD
  ///
  /// In ar, this message translates to:
  /// **'حتى 16 حرف'**
  String get playersNameLimit;

  /// [REVIEW] {n} words. Glossary key pack.word_count (ARABIC_LOCALIZATION.md §5). Note: Plural rule for 3–10 (كلمات) to decide
  ///
  /// In ar, this message translates to:
  /// **'{n} كلمة'**
  String packWordCount(String n);

  /// [REVIEW] Your role. Glossary key reveal.role_label (ARABIC_LOCALIZATION.md §5). Note: Sealed state uses دور
  ///
  /// In ar, this message translates to:
  /// **'دورك'**
  String get revealRoleLabel;

  /// [REVIEW] Category only. Glossary key reveal.category_only (ARABIC_LOCALIZATION.md §5). Note: برك = only
  ///
  /// In ar, this message translates to:
  /// **'الصنف برك'**
  String get revealCategoryOnly;

  /// [REVIEW] Clues. Glossary key phase.clues (ARABIC_LOCALIZATION.md §5). Note: MSA-leaning
  ///
  /// In ar, this message translates to:
  /// **'التلميحات'**
  String get phaseClues;

  /// [REVIEW] Voting. Glossary key phase.vote (ARABIC_LOCALIZATION.md §5). Note: MSA-leaning
  ///
  /// In ar, this message translates to:
  /// **'التصويت'**
  String get phaseVote;

  /// [REVIEW] You (marks own row). Glossary key vote.self (ARABIC_LOCALIZATION.md §5). Note: Gender-neutral usage to confirm; rule itself depends on PRD
  ///
  /// In ar, this message translates to:
  /// **'إنتي'**
  String get voteSelf;

  /// [REVIEW] New game. Glossary key home.new_game (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'طرح جديد'**
  String get homeNewGame;

  /// [REVIEW] Which of you?. Glossary key home.tagline (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'شكون فيكم؟'**
  String get homeTagline;

  /// [REVIEW] Add player. Glossary key players.add (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'زيد لعّاب'**
  String get playersAdd;

  /// [REVIEW] Player name. Glossary key players.name_label (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'اسم اللعّاب'**
  String get playersNameLabel;

  /// [REVIEW] e.g. Salma. Glossary key players.name_hint (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'مثلا: سلمى'**
  String get playersNameHint;

  /// [REVIEW] No players yet. Glossary key players.empty (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'مازال ما فمّا حتى لعّاب'**
  String get playersEmpty;

  /// [REVIEW] Add 4 players to start. Glossary key players.empty_hint (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'زيد 4 لعّابة باش تبداو'**
  String get playersEmptyHint;

  /// [REVIEW] Name already used. Glossary key error.name_duplicate (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'الاسم هذا موجود'**
  String get errorNameDuplicate;

  /// [REVIEW] Enter a name. Glossary key error.name_empty (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم'**
  String get errorNameEmpty;

  /// [REVIEW] You need at least 4 players. Glossary key error.min_players (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'لازمكم 4 لعّابة على الأقل'**
  String get errorMinPlayers;

  /// [REVIEW] Selected. Glossary key pack.selected (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'مختار'**
  String get packSelected;

  /// [REVIEW] Contains no words. Glossary key pack.empty (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'ما فيه حتى كلمة'**
  String get packEmpty;

  /// [REVIEW] Let's start. Glossary key action.start (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'هيّا نبداو'**
  String get actionStart;

  /// [REVIEW] Confirm. Glossary key action.confirm (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'أكّد'**
  String get actionConfirm;

  /// [REVIEW] Back. Glossary key action.back (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'ارجع'**
  String get actionBack;

  /// [REVIEW] Delete player. Glossary key action.delete_player (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'فسّخ اللعّاب'**
  String get actionDeletePlayer;

  /// [REVIEW] Change name. Glossary key action.rename (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'بدّل الاسم'**
  String get actionRename;

  /// [REVIEW] Retry. Glossary key action.retry (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'عاود'**
  String get actionRetry;

  /// [REVIEW] Play again. Glossary key action.play_again (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'طرح آخر'**
  String get actionPlayAgain;

  /// [REVIEW] Pass the phone to {name}. Glossary key handoff.pass_to (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'أعطي التليفون لـ {name}'**
  String handoffPassTo(String name);

  /// [REVIEW] I am {name}. Glossary key handoff.i_am (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'أنا {name}'**
  String handoffIAm(String name);

  /// [REVIEW] No one else should see. Glossary key privacy.only_you (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'ما يشوف حد غيرك'**
  String get privacyOnlyYou;

  /// [REVIEW] Role is hidden. Glossary key reveal.sealed (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'الدور مخبّي'**
  String get revealSealed;

  /// [REVIEW] Show me my role. Glossary key reveal.show (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'ورّيني دوري'**
  String get revealShow;

  /// [REVIEW] The secret word. Glossary key reveal.word_label (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'الكلمة السرّية'**
  String get revealWordLabel;

  /// [REVIEW] Category: {category}. Glossary key reveal.category (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'الصنف: {category}'**
  String revealCategory(String category);

  /// [REVIEW] You don't know the word. Glossary key reveal.no_word (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'ما تعرفش الكلمة'**
  String get revealNoWord;

  /// [REVIEW] Got it, hide. Glossary key reveal.ack (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'فهمت، خبّي'**
  String get revealAck;

  /// [REVIEW] Everyone has seen their role. Glossary key reveal.all_done (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'الكل شافوا دورهم'**
  String get revealAllDone;

  /// [REVIEW] Tie. We vote again between them.. Glossary key vote.tie (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'تعادل في الأصوات. نعاودو التصويت بيناتهم.'**
  String get voteTie;

  /// [REVIEW] Civilians won. Glossary key result.civilians_win (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'المدنيين ربحوا'**
  String get resultCiviliansWin;

  /// [REVIEW] The Impostor won. Glossary key result.impostor_wins (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'الإمبوستور ربح'**
  String get resultImpostorWins;

  /// [REVIEW] Draw. Glossary key result.draw (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'تعادل'**
  String get resultDraw;

  /// [REVIEW] Leave the game?. Glossary key dialog.quit_title (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'تخرج من الطرح؟'**
  String get dialogQuitTitle;

  /// [REVIEW] The current game is deleted and cannot be restored.. Glossary key dialog.quit_body (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'الطرح الحالي يتفسّخ وما تنجّمش ترجّعو.'**
  String get dialogQuitBody;

  /// [REVIEW] Leave. Glossary key dialog.quit_confirm (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'أخرج'**
  String get dialogQuitConfirm;

  /// [REVIEW] Keep playing. Glossary key dialog.quit_cancel (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'كمّل اللعب'**
  String get dialogQuitCancel;

  /// [REVIEW] One moment…. Glossary key state.loading (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'لحظة…'**
  String get stateLoading;

  /// [REVIEW] The game was paused. Continue where you stopped.. Glossary key state.resumed (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'الطرح توقّف. كمّلوا من وين وصلتوا.'**
  String get stateResumed;

  /// [REVIEW] Something went wrong. Try again.. Glossary key state.error (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'صار مشكل. عاود مرّة أخرى.'**
  String get stateError;

  /// [REVIEW] 4–12 players · one phone · no internet. Glossary key home.facts (ARABIC_LOCALIZATION.md §5).
  ///
  /// In ar, this message translates to:
  /// **'4–12 لعّابة · تليفون واحد · من غير أنترنات'**
  String get homeFacts;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
