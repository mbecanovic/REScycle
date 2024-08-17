import 'package:flutter/material.dart';


List<Market> _marketList = [
  const Market(
    name: 'MAXI',
    imgPath: "lib/data/pic/maxi.png",
    description: 'Marketi',
    currentPromotion: '10% popusta na mlecne proizvode',
    id: '1',
    active: true,
  ),
  const Market(
    name: 'Lidl',
    imgPath: "lib/data/pic/lidl.png",
    description: 'Marketi',
    currentPromotion: '20% popusta na vodu u staklenoj ambalazi',
    id: '2',
    active: true,
    
  ),
  const Market(
    name: 'Inersport',
    imgPath: "lib/data/pic/intersport.png",
    description: 'Sport',
    currentPromotion: '20% popusta na sportsku opremu izradjenu od recikliranog materijala',
    id: '3',
    active: true,
  ),
  const Market(
    name: 'HM',
    imgPath: "lib/data/pic/hm.jpg",
    description: 'Garderoba',
    currentPromotion: '20% popusta na odecu izradjenu od recikliranog materijala',
    id: '4',
    active: true,
  ),
  const Market(
    name: 'MCD',
    imgPath: "lib/data/pic/mc.png",
    description: 'Hrana',
    currentPromotion: '10% popusta',
    id: '5',
    active: true,
  ),
  const Market(
    name: 'Cinplexx',
    imgPath: "lib/data/pic/cineplex.png",
    description: 'Zabava',
    currentPromotion: '20% popusta',
    id: '6',
    active: true,
  ),
  const Market(
    name: 'Planeta',
    imgPath: "lib/data/pic/planeta.jpg",
    description: 'Sport',
    currentPromotion: '20% popusta',
    id: '7',
    active: false,
  ),
  const Market(
    name: 'Skijalista Srbije',
    imgPath: "lib/data/pic/ss.jpg",
    description: 'Sport',
    currentPromotion: '20% popusta',
    id: '8',
    active: true,
  ),
  const Market(
    name: 'Knjizara most',
    imgPath: "lib/data/pic/most.jpg",
    description: 'Zabava',
    currentPromotion: '20% popusta',
    id: '9',
    active: true,
  ),
  const Market(
    name: 'DIS',
    imgPath: "lib/data/pic/dis.jpg",
    description: 'Marketi',
    currentPromotion: '5% popusta na kremenadle',
    id: '10',
    active: true,
  ),
  const Market(
    name: 'Yettel',
    imgPath: "lib/data/pic/yettel.jpg",
    description: 'Elektronika i telekomunikacije',
    currentPromotion: 'Uz reciklirani telefon dodatnih 20% na prepaid kartice',
    id: '11',
    active: true,
  ),
  const Market(
    name: 'Google',
    imgPath: "lib/data/pic/google.jpg",
    description: 'Razno',
    currentPromotion: 'Vaucer 1 evro za kupovinu na Google Play prodavnici',
    id: '12',
    active: true,
  ),
];

class Market {
  final String name;
  final String imgPath;
  final String description;
  final String currentPromotion;
  final String id;
  final bool active;

  const Market({
    required this.name,
    required this.imgPath,
    required this.description,
    required this.currentPromotion,
    required this.id,
    required this.active,
  });
}

IconData getIconForDescription(String description) {
  switch (description) {
    case 'Marketi':
      return Icons.shopping_cart;
    case 'Sport':
      return Icons.sports_soccer;
    case 'Garderoba':
      return Icons.shopping_bag;
    case 'Hrana':
      return Icons.fastfood;
    case 'Zabava':
      return Icons.movie;
    case 'Elektronika i telekomunikacije':
      return Icons.electric_bolt;
    default:
      return Icons.store; // Default icon if description does not match any case
  }
}


List<Market> get marketList => _marketList;