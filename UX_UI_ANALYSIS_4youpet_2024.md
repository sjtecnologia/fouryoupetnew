# 🎨 **Análise UX/UI - 4youpet 2024**
## Análise da Interface Atual e Recomendações de Melhorias

**Versão:** 1.0  
**Data:** Dezembro 2024  
**Autor:** UX Expert  
**Status:** Draft

---

## 📊 **1. ANÁLISE DA INTERFACE ATUAL**

### 1.1 Estrutura Visual Atual
```
Design System Básico:
├── Cores
│   ├── Primary: #FF6F00 (Laranja)
│   ├── Secondary: #FFA100 (Laranja claro)
│   ├── Background: Gradiente laranja
│   └── Cards: Branco com sombra
├── Tipografia
│   ├── Font Family: 'mplus1' (padrão)
│   ├── Weights: Light, Regular, Medium, SemiBold, Bold, ExtraBold
│   └── Sizes: 14px (button), 22px (title)
└── Componentes
    ├── Cards: RoundedRectangleBorder (radius: 5-20px)
    ├── Buttons: ElevatedButton com gradiente
    └── Navigation: CurvedNavigationBar
```

### 1.2 Layout Principal
```
Home Screen:
├── AppBar: Logo centralizado + carrinho
├── Location Bar: Endereço do usuário
├── Banner Carousel: Promoções em carrossel
├── Service Grid: 4 botões principais
│   ├── PetShop (shop.png)
│   ├── Banho/Tosa (cut.png)
│   ├── Veterinário (VET_1.png)
│   └── Hotel (HOTEL_12.png)
└── Bottom Navigation: 8 abas principais
```

### 1.3 Navegação
```
Bottom Navigation:
├── Home (Icons.home)
├── Orders (Icons.shopify) + Badge
├── Events (Icons.calendar_today) + Badge
├── Hotels (Icons.hotel)
├── Pets (Icons.pets_sharp)
├── Profile (Icons.person)
├── Notifications (Icons.notification_important) + Badge
└── Search (Icons.search)
```

---

## ❌ **2. PROBLEMAS DE UX/UI IDENTIFICADOS**

### 2.1 Problemas de Hierarquia Visual
- ❌ **Falta de hierarquia clara** entre elementos
- ❌ **Cards de produtos muito básicos** sem destaque
- ❌ **Informações importantes perdidas** no layout
- ❌ **Falta de call-to-actions** claros

### 2.2 Problemas de Usabilidade
- ❌ **Navegação confusa** com 8 abas no bottom nav
- ❌ **Falta de feedback visual** em ações
- ❌ **Loading states inadequados** (apenas CircularProgressIndicator)
- ❌ **Falta de estados vazios** informativos

### 2.3 Problemas de Design
- ❌ **Design system inconsistente** (múltiplos estilos de botão)
- ❌ **Cores limitadas** (apenas laranja e branco)
- ❌ **Tipografia básica** sem variações suficientes
- ❌ **Espaçamentos inconsistentes**

### 2.4 Problemas de Acessibilidade
- ❌ **Contraste insuficiente** em alguns elementos
- ❌ **Falta de labels** para screen readers
- ❌ **Tamanhos de toque** inadequados
- ❌ **Falta de suporte** a modo escuro

---

## 🎯 **3. RECOMENDAÇÕES PARA NOVAS FEATURES**

### 3.1 Sistema de Avaliações

#### 3.1.1 Product Card Melhorado
```dart
// lib/features/reviews/widgets/enhanced_product_card.dart
class EnhancedProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem com overlay de desconto
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (product.discount > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '-${product.discount}%',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          
          // Informações do produto
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do produto
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                
                // Avaliação com estrelas
                Row(
                  children: [
                    StarRating(rating: product.averageRating),
                    SizedBox(width: 8),
                    Text(
                      '${product.averageRating.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '(${product.totalReviews})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                
                // Preço
                Row(
                  children: [
                    Text(
                      'R\$ ${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (product.originalPrice > product.price) ...[
                      SizedBox(width: 8),
                      Text(
                        'R\$ ${product.originalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 3.1.2 Tela de Avaliações
```dart
// lib/features/reviews/screens/product_reviews_screen.dart
class ProductReviewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avaliações'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumo das avaliações
          ReviewSummaryCard(
            averageRating: product.averageRating,
            totalReviews: product.totalReviews,
            ratingDistribution: product.ratingDistribution,
          ),
          
          // Filtros
          ReviewFilters(
            onFilterChanged: (filters) => _applyFilters(filters),
          ),
          
          // Lista de avaliações
          Expanded(
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) => ReviewCard(
                review: reviews[index],
                onHelpful: (reviewId) => _markAsHelpful(reviewId),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReviewForm(context),
        icon: Icon(Icons.star),
        label: Text('Avaliar'),
      ),
    );
  }
}
```

### 3.2 Sistema PIX

#### 3.2.1 Tela de Pagamento PIX
```dart
// lib/features/payments/screens/pix_payment_screen.dart
class PixPaymentScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagamento PIX'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header com valor
            PaymentHeader(
              amount: order.total,
              dueDate: order.dueDate,
            ),
            
            // QR Code
            PixQRCodeCard(
              qrCode: payment.qrCode,
              copyCode: payment.copyCode,
              onCopy: () => _copyToClipboard(payment.copyCode),
            ),
            
            // Instruções
            PixInstructionsCard(),
            
            // Status do pagamento
            PaymentStatusCard(
              status: payment.status,
              onCheckStatus: () => _checkPaymentStatus(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3.3 Sistema de Recomendações

#### 3.3.1 Seção de Recomendações
```dart
// lib/features/recommendations/widgets/recommendations_section.dart
class RecommendationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da seção
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.recommend, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text(
                'Recomendados para você',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Spacer(),
              TextButton(
                onPressed: () => _viewAllRecommendations(),
                child: Text('Ver todos'),
              ),
            ],
          ),
        ),
        
        // Lista horizontal de produtos
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(right: 12),
              child: RecommendationCard(
                product: recommendations[index],
                onTap: () => _navigateToProduct(recommendations[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### 3.4 Programa de Fidelidade

#### 3.4.1 Dashboard de Fidelidade
```dart
// lib/features/loyalty/screens/loyalty_dashboard.dart
class LoyaltyDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pontos'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Card de status
            LoyaltyStatusCard(
              currentLevel: user.loyaltyLevel,
              points: user.points,
              nextLevelPoints: user.nextLevelPoints,
              progress: user.progressToNextLevel,
            ),
            
            // Benefícios atuais
            LoyaltyBenefitsCard(
              benefits: user.currentBenefits,
            ),
            
            // Histórico de transações
            LoyaltyHistoryCard(
              transactions: user.loyaltyTransactions,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎨 **4. DESIGN SYSTEM PROPOSTO**

### 4.1 Paleta de Cores Expandida
```dart
// lib/design_system/colors.dart
class AppColors {
  // Cores primárias
  static const Color primary = Color(0xFF6B46C1); // Roxo moderno
  static const Color primaryLight = Color(0xFF9F7AEA);
  static const Color primaryDark = Color(0xFF553C9A);
  
  // Cores secundárias
  static const Color secondary = Color(0xFFF59E0B); // Amarelo
  static const Color accent = Color(0xFF10B981); // Verde
  
  // Cores neutras
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1F2937);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  
  // Cores de status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Cores de avaliação
  static const Color starFilled = Color(0xFFFCD34D);
  static const Color starEmpty = Color(0xFFE5E7EB);
}
```

### 4.2 Tipografia Melhorada
```dart
// lib/design_system/typography.dart
class AppTypography {
  static const String fontFamily = 'Inter';
  
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
```

### 4.3 Componentes Base
```dart
// lib/design_system/components/buttons.dart
class AppButtons {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0,
  );
  
  static ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: BorderSide(color: AppColors.primary),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
  
  static ButtonStyle text = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );
}
```

---

## 📱 **5. MELHORIAS DE UX PROPOSTAS**

### 5.1 Navegação Simplificada
```
Bottom Navigation Reduzida (5 abas):
├── Home (Icons.home)
├── Shop (Icons.store) - Produtos + Serviços
├── Orders (Icons.shopping_bag) + Badge
├── Profile (Icons.person)
└── More (Icons.more_horiz) - Menu com sub-opções
```

### 5.2 Estados de Loading Melhorados
```dart
// Skeleton loading para produtos
class ProductSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Skeleton(
            height: 200,
            width: double.infinity,
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 16, width: 150),
                SizedBox(height: 8),
                Skeleton(height: 14, width: 100),
                SizedBox(height: 8),
                Skeleton(height: 18, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5.3 Estados Vazios Informativos
```dart
// Empty state para carrinho vazio
class EmptyCartState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Seu carrinho está vazio',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Adicione produtos para começar suas compras',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToProducts(),
            icon: Icon(Icons.store),
            label: Text('Ver Produtos'),
          ),
        ],
      ),
    );
  }
}
```

### 5.4 Feedback Visual Melhorado
```dart
// Snackbar customizada
class CustomSnackBar {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
```

---

## 🎯 **6. WIREFRAMES E MOCKUPS**

### 6.1 Home Screen Redesenhada
```
┌─────────────────────────────────────┐
│ [☰] 4YouPet Logo    [🔍][🛒]      │
├─────────────────────────────────────┤
│ 📍 Rua das Flores, 123 - Centro     │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │        Banner Promocional       │ │
│ │     (Carrossel de imagens)      │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│ │ 🏪  │ │ ✂️  │ │ 🏥  │ │ 🏨  │   │
│ │Shop │ │Tosa │ │ Vet │ │Hotel│   │
│ └─────┘ └─────┘ └─────┘ └─────┘   │
├─────────────────────────────────────┤
│ ⭐ Recomendados para você           │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│ │Prod │ │Prod │ │Prod │ │Prod │   │
│ │ 4.5⭐│ │ 4.8⭐│ │ 4.2⭐│ │ 4.7⭐│   │
│ └─────┘ └─────┘ └─────┘ └─────┘   │
├─────────────────────────────────────┤
│ 🏆 Ofertas Especiais                │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│ │Prod │ │Prod │ │Prod │ │Prod │   │
│ │-20% │ │-15% │ │-30% │ │-25% │   │
│ └─────┘ └─────┘ └─────┘ └─────┘   │
└─────────────────────────────────────┘
```

### 6.2 Product Detail Screen
```
┌─────────────────────────────────────┐
│ [←] Ração Premium    [❤️][📤]      │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │        Imagem do Produto        │ │
│ │     (Carrossel de fotos)        │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ ⭐⭐⭐⭐⭐ 4.5 (127 avaliações)        │
│ R$ 89,90  R$ 99,90  -10%           │
├─────────────────────────────────────┤
│ Descrição do produto...             │
│ Tamanhos: [P] [M] [G] [GG]         │
├─────────────────────────────────────┤
│ Avaliações (127)                    │
│ ┌─────────────────────────────────┐ │
│ │ ⭐⭐⭐⭐⭐ Maria S.                 │ │
│ │ Ótima qualidade! Recomendo.     │ │
│ │ 👍 12  💬 Responder             │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [🛒 Adicionar ao Carrinho]         │
└─────────────────────────────────────┘
```

### 6.3 PIX Payment Screen
```
┌─────────────────────────────────────┐
│ [←] Pagamento PIX                   │
├─────────────────────────────────────┤
│ 💰 R$ 89,90                         │
│ Vencimento: 15/12/2024 23:59       │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │        QR Code PIX              │ │
│ │     (Código para escaneamento)  │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Código PIX:                         │
│ 00020126580014BR.GOV.BCB.PIX...    │
│ [📋 Copiar código]                 │
├─────────────────────────────────────┤
│ 📱 Instruções:                     │
│ 1. Abra o app do seu banco         │
│ 2. Escaneie o QR Code ou cole o    │
│    código PIX                      │
│ 3. Confirme o pagamento            │
├─────────────────────────────────────┤
│ Status: ⏳ Aguardando pagamento     │
│ [🔄 Verificar status]              │
└─────────────────────────────────────┘
```

---

## 📊 **7. MÉTRICAS DE UX**

### 7.1 Métricas de Usabilidade
- **Task Success Rate:** > 90%
- **Time to Complete Task:** < 30s
- **Error Rate:** < 5%
- **User Satisfaction:** > 4.5/5

### 7.2 Métricas de Performance
- **App Load Time:** < 3s
- **Screen Transition:** < 300ms
- **Image Load Time:** < 2s
- **Search Response:** < 1s

### 7.3 Métricas de Engajamento
- **Session Duration:** +40%
- **Pages per Session:** +60%
- **Return Rate:** +50%
- **Feature Adoption:** > 70%

---

## 🚀 **8. PLANO DE IMPLEMENTAÇÃO UX**

### 8.1 Fase 1: Fundação (4 semanas)
**Sprint 1-2: Design System**
- [ ] Criar paleta de cores expandida
- [ ] Definir tipografia consistente
- [ ] Criar componentes base
- [ ] Implementar tema claro/escuro

**Sprint 3-4: Componentes Core**
- [ ] ProductCard melhorado
- [ ] ReviewCard e StarRating
- [ ] PixPaymentCard
- [ ] LoadingStates e EmptyStates

### 8.2 Fase 2: Features (6 semanas)
**Sprint 5-6: Sistema de Avaliações**
- [ ] Tela de avaliações
- [ ] Formulário de review
- [ ] Filtros e ordenação
- [ ] Integração com produtos

**Sprint 7-8: Sistema PIX**
- [ ] Tela de pagamento PIX
- [ ] QR Code e códigos
- [ ] Status de pagamento
- [ ] Notificações de confirmação

**Sprint 9-10: Recomendações**
- [ ] Seção de recomendações
- [ ] Cards personalizados
- [ ] Tracking de comportamento
- [ ] Algoritmo de sugestões

### 8.3 Fase 3: Otimização (4 semanas)
**Sprint 11-12: UX Final**
- [ ] Navegação simplificada
- [ ] Micro-interações
- [ ] Acessibilidade
- [ ] Testes de usabilidade

---

## 🎨 **9. GUIDELINES DE DESIGN**

### 9.1 Princípios de Design
1. **Simplicidade:** Interface limpa e intuitiva
2. **Consistência:** Padrões visuais uniformes
3. **Acessibilidade:** Inclusivo para todos os usuários
4. **Performance:** Interface responsiva e rápida
5. **Emocional:** Conexão com o mundo pet

### 9.2 Padrões de Interação
- **Tap:** Feedback imediato com ripple effect
- **Swipe:** Gestos naturais para navegação
- **Pull-to-refresh:** Atualização de conteúdo
- **Infinite scroll:** Carregamento progressivo
- **Haptic feedback:** Resposta tátil em ações importantes

### 9.3 Responsividade
- **Mobile First:** Design otimizado para smartphones
- **Breakpoints:** Adaptação para tablets
- **Touch Targets:** Mínimo 44px de área de toque
- **Orientation:** Suporte a rotação de tela

---

## 📋 **10. CHECKLIST DE IMPLEMENTAÇÃO**

### Design System
- [ ] Paleta de cores definida
- [ ] Tipografia implementada
- [ ] Componentes base criados
- [ ] Tema claro/escuro
- [ ] Ícones consistentes

### Componentes
- [ ] ProductCard melhorado
- [ ] ReviewCard e StarRating
- [ ] PixPaymentCard
- [ ] RecommendationCard
- [ ] LoyaltyCard

### Telas
- [ ] Home redesenhada
- [ ] ProductDetail com avaliações
- [ ] PIXPaymentScreen
- [ ] ReviewsScreen
- [ ] LoyaltyDashboard

### UX
- [ ] Navegação simplificada
- [ ] Estados de loading
- [ ] Estados vazios
- [ ] Feedback visual
- [ ] Micro-interações

### Acessibilidade
- [ ] Contraste adequado
- [ ] Labels para screen readers
- [ ] Navegação por teclado
- [ ] Tamanhos de toque
- [ ] Suporte a modo escuro

---

**Documento aprovado em:** [Data]  
**Próxima revisão:** [Data + 30 dias]  
**Versão:** 1.0
