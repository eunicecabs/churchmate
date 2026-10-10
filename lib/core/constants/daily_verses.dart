/// Daily scripture verses shown on the dashboard.
///
/// The verse changes once per calendar day (device local date) and is the
/// same for every user on that day. It works offline: no network or Firestore
/// needed. To add more verses, just append to [dailyVerses]; the rotation
/// adjusts automatically.
class DailyVerse {
  final String text;
  final String reference;
  const DailyVerse(this.text, this.reference);
}

const List<DailyVerse> dailyVerses = [
  DailyVerse(
      "Don't let anyone look down on you because you are young, but set an example for the believers in speech, in conduct, in love, in faith and in purity.",
      '1 Timothy 4:12'),
  DailyVerse(
      '"For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, plans to give you hope and a future."',
      'Jeremiah 29:11'),
  DailyVerse('I can do all this through him who gives me strength.', 'Philippians 4:13'),
  DailyVerse(
      'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
      'Proverbs 3:5-6'),
  DailyVerse(
      'Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
      'Joshua 1:9'),
  DailyVerse(
      'So do not fear, for I am with you; do not be dismayed, for I am your God. I will strengthen you and help you; I will uphold you with my righteous right hand.',
      'Isaiah 41:10'),
  DailyVerse(
      'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.',
      'Romans 8:28'),
  DailyVerse('The Lord is my shepherd, I lack nothing.', 'Psalm 23:1'),
  DailyVerse(
      'But seek first his kingdom and his righteousness, and all these things will be given to you as well.',
      'Matthew 6:33'),
  DailyVerse('Your word is a lamp for my feet, a light on my path.', 'Psalm 119:105'),
  DailyVerse(
      'Do not conform to the pattern of this world, but be transformed by the renewing of your mind.',
      'Romans 12:2'),
  DailyVerse(
      'For it is by grace you have been saved, through faith, and this is not from yourselves, it is the gift of God.',
      'Ephesians 2:8'),
  DailyVerse(
      'But the fruit of the Spirit is love, joy, peace, forbearance, kindness, goodness, faithfulness, gentleness and self-control.',
      'Galatians 5:22-23'),
  DailyVerse(
      'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
      'John 3:16'),
  DailyVerse('God is our refuge and strength, an ever-present help in trouble.', 'Psalm 46:1'),
  DailyVerse(
      'Come to me, all you who are weary and burdened, and I will give you rest.',
      'Matthew 11:28'),
  DailyVerse(
      'For the Spirit God gave us does not make us timid, but gives us power, love and self-discipline.',
      '2 Timothy 1:7'),
  DailyVerse(
      'Take delight in the Lord, and he will give you the desires of your heart.',
      'Psalm 37:4'),
  DailyVerse(
      'Whatever you do, work at it with all your heart, as working for the Lord, not for human masters.',
      'Colossians 3:23'),
  DailyVerse(
      'Be on your guard; stand firm in the faith; be courageous; be strong. Do everything in love.',
      '1 Corinthians 16:13-14'),
  DailyVerse(
      'Now faith is confidence in what we hope for and assurance about what we do not see.',
      'Hebrews 11:1'),
  DailyVerse(
      'Taste and see that the Lord is good; blessed is the one who takes refuge in him.',
      'Psalm 34:8'),
  DailyVerse(
      'He has shown you, O mortal, what is good. And what does the Lord require of you? To act justly and to love mercy and to walk humbly with your God.',
      'Micah 6:8'),
  DailyVerse(
      'In the same way, let your light shine before others, that they may see your good deeds and glorify your Father in heaven.',
      'Matthew 5:16'),
  DailyVerse('Commit to the Lord whatever you do, and he will establish your plans.', 'Proverbs 16:3'),
  DailyVerse(
      'The Lord has done it this very day; let us rejoice today and be glad.',
      'Psalm 118:24'),
  DailyVerse(
      'May the God of hope fill you with all joy and peace as you trust in him, so that you may overflow with hope by the power of the Holy Spirit.',
      'Romans 15:13'),
  DailyVerse(
      "Because of the Lord's great love we are not consumed, for his compassions never fail. They are new every morning; great is your faithfulness.",
      'Lamentations 3:22-23'),
  DailyVerse(
      'The Lord is my light and my salvation, whom shall I fear? The Lord is the stronghold of my life, of whom shall I be afraid?',
      'Psalm 27:1'),
  DailyVerse(
      'If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault, and it will be given to you.',
      'James 1:5'),
  DailyVerse('Cast all your anxiety on him because he cares for you.', '1 Peter 5:7'),
  DailyVerse(
      'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.',
      'Philippians 4:6'),
  DailyVerse(
      'Be strong and courageous. Do not be afraid or terrified because of them, for the Lord your God goes with you; he will never leave you nor forsake you.',
      'Deuteronomy 31:6'),
  DailyVerse(
      'And surely I am with you always, to the very end of the age.',
      'Matthew 28:20'),
  DailyVerse(
      'I praise you because I am fearfully and wonderfully made; your works are wonderful, I know that full well.',
      'Psalm 139:14'),
  DailyVerse(
      'Let us not become weary in doing good, for at the proper time we will reap a harvest if we do not give up.',
      'Galatians 6:9'),
  DailyVerse(
      'How can a young person stay on the path of purity? By living according to your word.',
      'Psalm 119:9'),
  DailyVerse(
      'I lift up my eyes to the mountains, where does my help come from? My help comes from the Lord, the Maker of heaven and earth.',
      'Psalm 121:1-2'),
  DailyVerse(
      'Be kind and compassionate to one another, forgiving each other, just as in Christ God forgave you.',
      'Ephesians 4:32'),
  DailyVerse(
      'A new command I give you: Love one another. As I have loved you, so you must love one another.',
      'John 13:34'),
  DailyVerse(
      'But God demonstrates his own love for us in this: While we were still sinners, Christ died for us.',
      'Romans 5:8'),
  DailyVerse(
      'But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.',
      'Isaiah 40:31'),
  DailyVerse(
      'And now these three remain: faith, hope and love. But the greatest of these is love.',
      '1 Corinthians 13:13'),
];

/// Returns the verse for [date] (defaults to today). Same date -> same verse.
DailyVerse verseForDate([DateTime? date]) {
  final d = date ?? DateTime.now();
  // Use UTC-constructed dates so DST/time-of-day never shifts the day count.
  final days = DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(2024, 1, 1)).inDays;
  return dailyVerses[days % dailyVerses.length];
}
