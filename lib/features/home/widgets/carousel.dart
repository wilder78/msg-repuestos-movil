// lib/features/home/widgets/carousel.dart

import 'dart:async';

import 'package:flutter/material.dart';

class HomeCarousel extends StatefulWidget {
  const HomeCarousel({super.key});

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  final PageController _pageController = PageController();
  late final Timer _timer;
  int _currentPage = 0;

  final List<_CarouselItem> _items = const [
    _CarouselItem(
      title: 'Ofertas especiales en repuestos',
      subtitle: 'Hasta 30% de descuento',
      color: Color(0xFF11244D),
    ),
    _CarouselItem(
      title: 'Nuevos productos disponibles',
      subtitle: 'Revisa nuestro catálogo',
      color: Color(0xFF1C3790),
    ),
    _CarouselItem(
      title: 'Envío gratis por compras mayores',
      subtitle: 'Aplica términos y condiciones',
      color: Color(0xFF2161FF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _nextPage());
  }

  void _nextPage() {
    final nextPage = (_currentPage + 1) % _items.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) =>
                _CarouselSlide(item: _items[index]),
          ),
        ),
        const SizedBox(height: 10),
        _DotsIndicator(count: _items.length, currentIndex: _currentPage),
      ],
    );
  }
}

class _CarouselItem {
  final String title;
  final String subtitle;
  final Color color;

  const _CarouselItem({
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _CarouselSlide extends StatelessWidget {
  const _CarouselSlide({required this.item});

  final _CarouselItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? const Color(0xFF11244D)
                : const Color(0xFF11244D).withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
