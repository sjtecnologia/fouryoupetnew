import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_typography.dart';
import '../../design_system/components/app_button.dart';
import '../../models/loyalty/loyalty.dart';
import '../../models/loyalty/loyalty_manager.dart';
import '../../models/user/user_manager.dart';
import 'package:share_plus/share_plus.dart';

/// Tela principal do programa de fidelidade
class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userManager = context.read<UserManager>();
      if (userManager.isLoggedIn) {
        final loyaltyManager = context.read<LoyaltyManager>();
        // Primeiro recalcular pontos para corrigir qualquer inconsistência
        await loyaltyManager.recalculatePoints();
        // Depois carregar os dados
        loyaltyManager.loadLoyaltyProgram();
        loyaltyManager.loadTransactions();
        loyaltyManager.loadAvailableRewards();
        loyaltyManager.loadRedemptions();
        // Iniciar listener em tempo real
        loyaltyManager.startRealtimeListener();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManager>(
      builder: (context, userManager, _) {
        if (!userManager.isLoggedIn) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Programa de Fidelidade'),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 111, 0),
                    Color.fromARGB(255, 255, 161, 0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.login,
                          size: 64,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Faça login para acessar',
                          style: AppTypography.h4,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Você precisa estar logado para visualizar seu programa de fidelidade',
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Fazer Login',
                          onPressed: () {
                            Navigator.of(context).pushNamed('/login');
                          },
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Programa de Fidelidade'),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Meus Pontos'),
                Tab(text: 'Recompensas'),
                Tab(text: 'Histórico'),
                Tab(text: 'Indicar Amigo'),
              ],
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 111, 0),
                  Color.fromARGB(255, 255, 161, 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  top:
                      MediaQuery.of(context).padding.top + kToolbarHeight + 30),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPointsTab(),
                  _buildRewardsTab(),
                  _buildHistoryTab(),
                  _buildReferralTab(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsTab() {
    return Consumer<LoyaltyManager>(
      builder: (context, loyaltyManager, child) {
        if (loyaltyManager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (loyaltyManager.error != null) {
          return _buildErrorState(loyaltyManager.error!);
        }

        final program = loyaltyManager.loyaltyProgram;
        if (program == null) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPointsCard(program),
              const SizedBox(height: 24),
              _buildTierCard(program),
              const SizedBox(height: 24),
              _buildBenefitsCard(program),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardsTab() {
    return Consumer<LoyaltyManager>(
      builder: (context, loyaltyManager, child) {
        if (loyaltyManager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (loyaltyManager.error != null) {
          return _buildErrorState(loyaltyManager.error!);
        }

        final rewards = loyaltyManager.availableRewards;
        if (rewards.isEmpty) {
          return _buildEmptyRewardsState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            final reward = rewards[index];
            return _buildRewardCard(reward);
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<LoyaltyManager>(
      builder: (context, loyaltyManager, child) {
        if (loyaltyManager.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (loyaltyManager.error != null) {
          return _buildErrorState(loyaltyManager.error!);
        }

        final transactions = loyaltyManager.transactions;
        if (transactions.isEmpty) {
          return _buildEmptyHistoryState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionCard(transaction);
          },
        );
      },
    );
  }

  Widget _buildPointsCard(LoyaltyProgram program) {
    return Consumer<LoyaltyManager>(
      builder: (context, loyaltyManager, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Meus Pontos',
                  style: AppTypography.h5,
                ),
                const SizedBox(height: 16),
                Text(
                  '${program.currentPoints}',
                  style: AppTypography.h1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'pontos disponíveis',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Ganhos',
                      '${loyaltyManager.netEarnedPoints}',
                      Icons.trending_up,
                      AppColors.success,
                    ),
                    _buildStatItem(
                      'Resgatados',
                      '${program.totalPointsRedeemed}',
                      Icons.redeem,
                      AppColors.warning,
                    ),
                    _buildStatItem(
                      'Tier',
                      _getTierName(program.currentTier),
                      Icons.star,
                      _getTierColor(program.currentTier),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.h6.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTierCard(LoyaltyProgram program) {
    final nextTier = _getNextTier(program.currentTier);
    final progress = _getTierProgress(program);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: _getTierColor(program.currentTier),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tier ${_getTierName(program.currentTier)}',
                  style: AppTypography.h6,
                ),
                const Spacer(),
                if (nextTier != null)
                  Text(
                    'Próximo: ${_getTierName(nextTier)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (nextTier != null) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.outline,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTierColor(program.currentTier),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${program.pointsToNextTier} pontos para o próximo tier',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Você está no tier máximo!',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard(LoyaltyProgram program) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benefícios do Tier ${_getTierName(program.currentTier)}',
              style: AppTypography.h6,
            ),
            const SizedBox(height: 16),
            ...program.currentTierBenefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final canRedeem = context.read<LoyaltyManager>().canRedeemReward(reward);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (reward.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      reward.image!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: AppColors.surfaceVariant,
                          child: const Icon(
                            Icons.card_giftcard,
                            color: AppColors.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.name,
                        style: AppTypography.h6,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reward.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reward.discountText,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${reward.pointsRequired} pts',
                      style: AppTypography.h6.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: canRedeem ? 'Resgatar' : 'Pontos insuficientes',
                      onPressed: canRedeem ? () => _redeemReward(reward) : null,
                      type: canRedeem
                          ? AppButtonType.primary
                          : AppButtonType.secondary,
                      size: AppButtonSize.small,
                    ),
                  ],
                ),
              ],
            ),
            if (reward.stock > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: reward.redeemedCount / reward.stock,
                backgroundColor: AppColors.outline,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                '${reward.remainingStock} restantes',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(PointsTransaction transaction) {
    final isPositive = transaction.points > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPositive
              ? AppColors.success.withOpacity(0.1)
              : AppColors.error.withOpacity(0.1),
          child: Icon(
            isPositive ? Icons.add : Icons.remove,
            color: isPositive ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text(
          transaction.description,
          style: AppTypography.bodyMedium,
        ),
        subtitle: Text(
          _formatDate(transaction.createdAt),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          '${isPositive ? '+' : ''}${transaction.points}',
          style: AppTypography.bodyMedium.copyWith(
            color: isPositive ? AppColors.success : AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    print(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar dados',
            style: AppTypography.h5,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Tentar novamente',
            onPressed: () {
              context.read<LoyaltyManager>().loadLoyaltyProgram();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Programa de fidelidade',
            style: AppTypography.h5,
          ),
          const SizedBox(height: 8),
          Text(
            'Comece a comprar para ganhar pontos!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRewardsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma recompensa disponível',
            style: AppTypography.h5,
          ),
          const SizedBox(height: 8),
          Text(
            'Novas recompensas serão adicionadas em breve!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação ainda',
            style: AppTypography.h5,
          ),
          const SizedBox(height: 8),
          Text(
            'Suas transações de pontos aparecerão aqui',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _redeemReward(Reward reward) async {
    final success =
        await context.read<LoyaltyManager>().redeemReward(reward.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recompensa "${reward.name}" resgatada com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<LoyaltyManager>().error ??
                'Erro ao resgatar recompensa'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getTierName(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Prata';
      case LoyaltyTier.gold:
        return 'Ouro';
      case LoyaltyTier.platinum:
        return 'Platina';
    }
  }

  Widget _buildReferralTab() {
    return Consumer2<LoyaltyManager, UserManager>(
      builder: (context, loyaltyManager, userManager, child) {
        final userapp = userManager.userapp;

        // Se o usuário não tem código, gerar um
        if (userapp != null &&
            userapp.id != null &&
            (userapp.referralCode == null || userapp.referralCode!.isEmpty)) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final code = loyaltyManager.generateReferralCode(userapp.id!);
            userapp.referralCode = code;
            await userapp.saveData();
            print('✅ Código de indicação gerado: $code');
          });
        }

        final referralCode = userapp?.referralCode ?? '';

        print('🔍 ReferralTab - userapp: ${userapp?.id}');
        print('🔍 ReferralTab - referralCode: "$referralCode"');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Código de indicação
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Seu Código de Indicação',
                        style: AppTypography.h4,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: referralCode.isEmpty
                            ? Text(
                                'Carregando...',
                                style: AppTypography.h5.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                referralCode,
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: referralCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Código copiado!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side:
                                    const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.copy, size: 24),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Copiar',
                                    style: AppTypography.buttonSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Share.share(
                                  'Use meu código $referralCode ao se cadastrar no 4YouPet e ganhe pontos na sua primeira compra! 🎁',
                                  subject: 'Convite 4YouPet',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shadowColor: AppColors.shadowLight,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.share, size: 24),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Compartilhar',
                                    style: AppTypography.buttonSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Como funciona
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Como Funciona',
                            style: AppTypography.h4,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildHowItWorksStep(
                        context,
                        '1',
                        'Compartilhe seu código',
                        'Envie seu código de indicação para amigos e familiares.',
                      ),
                      const SizedBox(height: 12),
                      _buildHowItWorksStep(
                        context,
                        '2',
                        'Amigo se cadastra',
                        'Seu amigo usa o código ao criar conta no 4YouPet.',
                      ),
                      const SizedBox(height: 12),
                      _buildHowItWorksStep(
                        context,
                        '3',
                        'Primeira compra',
                        'Quando seu amigo fizer a primeira compra, ambos ganham pontos!',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recompensas
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recompensas',
                            style: AppTypography.h4,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRewardItem(
                        context,
                        '🎁',
                        'Seu amigo ganha',
                        '100 pontos',
                        'Ao fazer a primeira compra',
                      ),
                      const SizedBox(height: 12),
                      _buildRewardItem(
                        context,
                        '🎉',
                        'Você ganha',
                        '200 pontos',
                        'Quando seu amigo faz a primeira compra',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Estatísticas
              FutureBuilder<int>(
                future: _getReferralCount(userapp?.id),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$count',
                            style: AppTypography.h2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            count == 1 ? 'Amigo Indicado' : 'Amigos Indicados',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHowItWorksStep(
    BuildContext context,
    String number,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardItem(
    BuildContext context,
    String emoji,
    String title,
    String points,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  points,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _getReferralCount(String? userId) async {
    if (userId == null) return 0;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('userapp')
          .where('referredBy', isEqualTo: userId)
          .where('hasCompletedFirstPurchase', isEqualTo: true)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Color _getTierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return AppColors.bronze;
      case LoyaltyTier.silver:
        return AppColors.silver;
      case LoyaltyTier.gold:
        return AppColors.gold;
      case LoyaltyTier.platinum:
        return AppColors.platinum;
    }
  }

  LoyaltyTier? _getNextTier(LoyaltyTier currentTier) {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return LoyaltyTier.silver;
      case LoyaltyTier.silver:
        return LoyaltyTier.gold;
      case LoyaltyTier.gold:
        return LoyaltyTier.platinum;
      case LoyaltyTier.platinum:
        return null;
    }
  }

  double _getTierProgress(LoyaltyProgram program) {
    final nextTier = _getNextTier(program.currentTier);
    if (nextTier == null) return 1.0;

    int currentThreshold;
    int nextThreshold;

    switch (program.currentTier) {
      case LoyaltyTier.bronze:
        currentThreshold = 0;
        nextThreshold = 2000;
        break;
      case LoyaltyTier.silver:
        currentThreshold = 2000;
        nextThreshold = 5000;
        break;
      case LoyaltyTier.gold:
        currentThreshold = 5000;
        nextThreshold = 10000;
        break;
      case LoyaltyTier.platinum:
        return 1.0;
    }

    final progress = (program.currentPoints - currentThreshold) /
        (nextThreshold - currentThreshold);
    return progress.clamp(0.0, 1.0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
