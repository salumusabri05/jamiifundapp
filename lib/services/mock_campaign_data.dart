import 'package:jamiifund/models/campaign.dart';

class MockCampaignData {
  // Generate a list of mock campaigns for testing
  static List<Campaign> getMockCampaigns() {
    final now = DateTime.now();
    return [
      Campaign(
        id: '1',
        title: "Help Amina continue her studies 🎓",
        description: "Amina is a bright student from Arusha who needs financial support to complete her university education. Your contribution will help cover her tuition fees, books, and accommodation.",
        category: "Education",
        goalAmount: 3000000, // 3 million TZS
        currentAmount: 2040000, // 68% funded
        endDate: now.add(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 15)),
        imageUrl: "https://images.unsplash.com/photo-1515115041507-4a4ee3100994",
        isFeatured: true,
        donorCount: 78,
        createdByName: "John Doe",
      ),
      Campaign(
        id: '2',
        title: "Support Rehema's medical treatment 🏥",
        description: "Rehema needs urgent medical treatment for a chronic condition. Your donations will help cover her hospital bills and medication.",
        category: "Health",
        goalAmount: 5000000, // 5 million TZS
        currentAmount: 2250000, // 45% funded
        endDate: now.add(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 10)),
        imageUrl: "https://images.unsplash.com/photo-1631815588090-d1bcbe9adb20",
        isFeatured: true,
        donorCount: 56,
        createdByName: "Sarah Johnson",
      ),
      Campaign(
        id: '3',
        title: "Community clean water project 💧",
        description: "Help bring clean water to a rural community in Mwanza by funding the construction of wells and water distribution systems.",
        category: "Community",
        goalAmount: 7500000, // 7.5 million TZS
        currentAmount: 5400000, // 72% funded
        endDate: now.add(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 25)),
        imageUrl: "https://images.unsplash.com/photo-1535890696255-dd5bcd79e6df",
        isFeatured: true,
        donorCount: 124,
        createdByName: "Tanzania Water Initiative",
      ),
      Campaign(
        id: '4',
        title: "Rebuild homes after flooding 🏠",
        description: "Recent floods have destroyed homes in coastal areas. Help families rebuild their lives by contributing to this emergency fund.",
        category: "Emergencies",
        goalAmount: 10000000, // 10 million TZS
        currentAmount: 3800000, // 38% funded
        endDate: now.add(const Duration(days: 20)),
        createdAt: now.subtract(const Duration(days: 5)),
        imageUrl: "https://images.unsplash.com/photo-1469571486292-0ba58a3f068b",
        isFeatured: false,
        donorCount: 93,
        createdByName: "Emergency Relief Fund",
      ),
      Campaign(
        id: '5',
        title: "Community School Library 📚",
        description: "Help us build a library for our local primary school to improve literacy and access to educational resources.",
        category: "Education",
        goalAmount: 4000000, // 4 million TZS
        currentAmount: 3000000, // 75% funded
        endDate: now.add(const Duration(days: 22)),
        createdAt: now.subtract(const Duration(days: 30)),
        imageUrl: "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f",
        isFeatured: false,
        donorCount: 67,
        createdByName: "Sabri", // Current user's campaign
      ),
    ];
  }

  // Get featured campaigns
  static List<Campaign> getFeaturedCampaigns() {
    return getMockCampaigns().where((campaign) => campaign.isFeatured).toList();
  }

  // Get campaigns by category
  static List<Campaign> getCampaignsByCategory(String category) {
    return getMockCampaigns().where((campaign) => campaign.category == category).toList();
  }

  // Get user campaigns
  static List<Campaign> getUserCampaigns(String username) {
    return getMockCampaigns().where((campaign) => campaign.createdByName == username).toList();
  }
}
