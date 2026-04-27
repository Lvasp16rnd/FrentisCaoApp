import 'package:frentis_cao/models/content_models.dart';

/// Dados mock para popular as telas durante o desenvolvimento.
class MockData {
  MockData._();

  static const List<PostModel> posts = [
    PostModel(
      id: '1',
      orgName: 'Patinhas Felizes',
      orgAvatarUrl: '',
      imageUrl: '',
      title: 'Campanha de Natal Solidário',
      description: 'Ajude-nos a dar um Natal especial para mais de 200 animais resgatados. Precisamos de ração, cobertores e muito carinho!',
      tag: 'Doar',
      fullDescription: 'A ONG Patinhas Felizes está realizando sua campanha anual de Natal Solidário. Nosso objetivo é arrecadar ração, cobertores, medicamentos e brinquedos para os mais de 200 animais que estão sob nossos cuidados.\n\nCada doação faz uma enorme diferença na vida desses animais que foram resgatados de situações de abandono e maus-tratos. Com sua ajuda, podemos garantir que todos tenham um Natal especial.\n\nAceitamos doações em dinheiro via PIX ou doações de materiais que podem ser entregues em nosso abrigo.',
    ),
    PostModel(
      id: '2',
      orgName: 'Amigos dos Bichos',
      orgAvatarUrl: '',
      imageUrl: '',
      title: 'Novo abrigo inaugurado!',
      description: 'Estamos felizes em anunciar a inauguração do nosso novo espaço com capacidade para 50 animais.',
      tag: 'Doar',
      fullDescription: 'Após dois anos de trabalho árduo e muita dedicação da comunidade, inauguramos nosso novo abrigo! O espaço conta com área de 500m², com canis individuais, área de recreação, enfermaria e cozinha.\n\nPrecisamos de ajuda para manter este espaço funcionando. Os custos mensais de manutenção são significativos e contamos com a generosidade de todos para manter este sonho vivo.',
    ),
    PostModel(
      id: '3',
      orgName: 'SOS Animal',
      orgAvatarUrl: '',
      imageUrl: '',
      title: 'Resgate de 15 cães em situação de maus-tratos',
      description: 'Realizamos o resgate de 15 cães que viviam em condições precárias. Todos estão recebendo cuidados veterinários.',
      tag: 'Doar',
      fullDescription: 'Na última semana, nossa equipe realizou um resgate emergencial de 15 cães que viviam em condições extremamente precárias. Os animais apresentavam sinais de desnutrição, parasitas e ferimentos.\n\nTodos estão recebendo atendimento veterinário completo, incluindo vermifugação, vacinação e tratamento de feridas. Alguns precisarão de cirurgias.\n\nO custo total estimado dos tratamentos é de R\$ 12.000. Qualquer valor ajuda!',
    ),
  ];

  static const List<AnimalModel> animals = [
    AnimalModel(
      id: '1', name: 'Thor', breed: 'Labrador', age: '2 anos', imageUrl: '', gender: 'Macho',
      size: 'Grande', vaccinated: true, castrated: true,
      about: 'Thor é um labrador muito dócil e brincalhão. Adora correr e brincar com bolas. É muito carinhoso com crianças e se dá bem com outros cães.',
    ),
    AnimalModel(
      id: '2', name: 'Luna', breed: 'SRD', age: '1 ano', imageUrl: '', gender: 'Fêmea',
      size: 'Médio', vaccinated: true, castrated: false,
      about: 'Luna é uma cadelinha meiga e tranquila. Gosta de ficar no colo e receber carinho. É ideal para apartamentos.',
    ),
    AnimalModel(
      id: '3', name: 'Bob', breed: 'Pinscher', age: '3 anos', imageUrl: '', gender: 'Macho',
      size: 'Pequeno', vaccinated: true, castrated: true,
      about: 'Bob é pequeno no tamanho mas grande no coração! Muito esperto e protetor.',
    ),
    AnimalModel(
      id: '4', name: 'Mel', breed: 'Golden Retriever', age: '6 meses', imageUrl: '', gender: 'Fêmea',
      size: 'Grande', vaccinated: true, castrated: false,
      about: 'Mel é uma filhote muito sapeca e cheia de energia! Está aprendendo comandos básicos.',
    ),
    AnimalModel(
      id: '5', name: 'Rex', breed: 'Pastor Alemão', age: '4 anos', imageUrl: '', gender: 'Macho',
      size: 'Grande', vaccinated: true, castrated: true,
      about: 'Rex é um cão leal e inteligente. Foi treinado e obedece comandos básicos.',
    ),
    AnimalModel(
      id: '6', name: 'Nina', breed: 'SRD', age: '8 meses', imageUrl: '', gender: 'Fêmea',
      size: 'Pequeno', vaccinated: true, castrated: false,
      about: 'Nina é uma cachorrinha muito tímida no começo, mas quando ganha confiança vira a melhor amiga do mundo.',
    ),
  ];

  static const List<CampaignModel> campaigns = [
    CampaignModel(
      id: '1', title: 'Campanha de Castração', location: 'Parque Municipal, Centro',
      date: '15 Mai 2026', imageUrl: '', type: 'Castração',
      description: 'A campanha de castração gratuita atenderá cães e gatos de famílias de baixa renda. Serão disponibilizadas 100 vagas.',
      instructions: 'O animal deve estar em jejum de 8 horas. Traga em caixa de transporte ou com guia e coleira. Documentos: RG e comprovante de residência.',
    ),
    CampaignModel(
      id: '2', title: 'Feira de Adoção', location: 'Shopping Riverside',
      date: '22 Mai 2026', imageUrl: '', type: 'Adoção',
      description: 'Venha conhecer nossos animais disponíveis para adoção! Todos vacinados, vermifugados e castrados.',
      instructions: 'Para adotar, traga RG, CPF e comprovante de residência. Menores de 18 anos devem estar acompanhados dos pais.',
    ),
    CampaignModel(
      id: '3', title: 'Vacinação Antirrábica', location: 'UBS Centro, Rua das Flores',
      date: '01 Jun 2026', imageUrl: '', type: 'Vacinação',
      description: 'Campanha de vacinação antirrábica gratuita para cães e gatos.',
      instructions: 'O animal deve ter pelo menos 3 meses de idade e estar saudável. Cães devem usar coleira e guia. Gatos em caixa de transporte.',
    ),
    CampaignModel(
      id: '4', title: 'Mutirão de Banho e Tosa', location: 'Praça da Liberdade',
      date: '10 Jun 2026', imageUrl: '', type: 'Cuidados',
      description: 'Mutirão gratuito de banho e tosa para cães de famílias carentes.',
      instructions: 'Traga seu cão com guia e coleira. Atendimento por ordem de chegada. Limite de 1 animal por família.',
    ),
  ];
}
