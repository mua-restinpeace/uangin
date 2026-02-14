class OnBoardingItem {
  final String image;
  final String title;
  final String description;

  const OnBoardingItem(
      {required this.image, required this.title, required this.description});
}

const onBoardingItems = [
  OnBoardingItem(
      image: 'lib/assets/images/Plain credit card-cuate 1.svg',
      title: 'Track Every Rupiah, Effortlessly',
      description:
          'Keep an eye on your weekly allowance and know exactly where your money goes—without the stress.'),
  OnBoardingItem(
      image: 'lib/assets/images/Wallet-cuate 1.svg',
      title: 'Weekly Allowance, Fully Controlled',
      description:
          'Set your weekly budget, track your spending, and stay in control from day one.'),
  OnBoardingItem(
      image: 'lib/assets/images/Personal finance-cuate 1.svg',
      title: 'Leftover Money? It Goes to Savings',
      description:
          'Any unspent allowance at the end of the week is automatically saved for your future goals.'),
  OnBoardingItem(
      image: 'lib/assets/images/Plain credit card-rafiki 1.svg',
      title: 'Start Building Better Money Habits!',
      description:
          ''),
];
