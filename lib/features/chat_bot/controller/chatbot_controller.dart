import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/constant/app_constants.dart';

class ChatBotController extends GetxController {
  RxBool isLoading = false.obs;

  final nameController = TextEditingController();
  final educationController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  final interestsController = TextEditingController();

  final List<TextEditingController> skillControllers = [];

  void addSkillField() {
    skillControllers.add(TextEditingController());
    update();
  }

  void removeSkillField(int index) {
    skillControllers.removeAt(index);
    update();
  }

  void resetFields() {
    nameController.clear();
    educationController.clear();
    locationController.clear();
    bioController.clear();
    interestsController.clear();
    for (var controller in skillControllers) {
      controller.clear();
    }
    skillControllers.clear();
    update();
  }

  Future<String> generateCareerPath01() async {
    isLoading.value = true;

    try {
      final skills = skillControllers.map((e) => e.text).where((e) => e.trim().isNotEmpty).join(', ');

      final prompt = '''
You are a highly intelligent and localized career counselor. Your job is to guide the user based on the following profile:

Name: ${nameController.text}
Education: ${educationController.text}
Location: ${locationController.text}
Bio: ${bioController.text}
Interests: ${interestsController.text}
Skills: $skills

Respond strictly in clean HTML format (using <h2>, <p>, <ul>, <li>, <b>, etc). Do NOT use markdown or asterisks (* or **). The response must be directly renderable as HTML.

Provide a detailed career suggestion tailored specifically for someone from "${locationController.text}". Your response must include:

<h2>1. Best Suited Field(s) with Reasons</h2>
<h2>2. Career Scope in the User's Country (${locationController.text})</h2>
<h2>3. High-Demand Regions or Cities in that Country</h2>
<h2>4. Expected Salary Range in Local Currency (PKR if in Pakistan)</h2>
<h2>5. Career Roadmap and Learning Path</h2>
<h2>6. Key Platforms for Learning</h2>
<h2>7. Real-World Applications and Future Growth</h2>
<h2>8. Local Companies or Industries Hiring for that Field</h2>

Make sure the entire response is contextual to the user's profile and country. Do NOT include global/general content. Respond only in structured and valid HTML that can be rendered directly in a Flutter HTML widget.
''';



      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: AppConstants.geminiKey,
      );

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      isLoading.value = false;

      String? responseText = response.text?.contains('<') == true ? response.text! : "<p>No valid HTML response from Gemini.</p>";

      if (responseText.startsWith('```html') ) {
        responseText = responseText.substring(7);
      }

      if (responseText.endsWith('```')) {
        responseText = responseText.substring(0, responseText.length - 3);
      }

      if (responseText.endsWith('')) {
        responseText = responseText.substring(0, responseText.length - 3);
      }

      if(responseText.endsWith('```html')) {
        responseText = responseText.substring(0, responseText.length - 7);
      }


      return responseText;
    } catch (e) {
      isLoading.value = false;
      debugPrint("Error: $e");
      return "<p>No valid HTML response from Gemini.</p>";
    }
  }

  Future<String> generateCareerPath() async {
    isLoading.value = true;

    try {
      final skills = skillControllers.map((e) => e.text).where((e) => e.trim().isNotEmpty).join(', ');

      final prompt = '''
You are a highly intelligent and localized career counselor. Your job is to guide the user based on the following profile:

Name: ${nameController.text}
Education: ${educationController.text}
Location: ${locationController.text}
Bio: ${bioController.text}
Interests: ${interestsController.text}
Skills: $skills

Respond strictly in clean HTML format with proper styling. The response must be directly renderable as HTML and visually appealing.

Use this exact HTML structure with styling:

<div style="font-family: Arial, sans-serif; color: #333; max-width: 800px; margin: 0 auto;">
  <h1 style="color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 8px; margin-bottom: 20px;">Career Path Recommendation for ${nameController.text}</h1>
  
  <!-- Best Suited Fields -->
  <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <h2 style="color: #2980b9; margin-top: 0;">1. Best Suited Field(s)</h2>
    <p><b>Analysis:</b> Based on your profile, these fields align best with your skills and interests:</p>
    <ul style="padding-left: 20px;">
      <li><b>Field 1:</b> Detailed explanation why this fits you including your skills in $skills</li>
      <li><b>Field 2:</b> Detailed explanation why this fits you considering your interest in ${interestsController.text}</li>
    </ul>
  </div>

  <!-- Career Scope -->
  <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <h2 style="color: #2980b9; margin-top: 0;">2. Career Scope in ${locationController.text}</h2>
    <p>Detailed analysis of current market demand, growth trends, and future prospects specifically in ${locationController.text}:</p>
    <ul style="padding-left: 20px;">
      <li>Current industry size and major players</li>
      <li>Projected growth over next 5 years</li>
      <li>Government initiatives supporting this field</li>
    </ul>
  </div>

  <!-- High-Demand Regions -->
  <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <h2 style="color: #2980b9; margin-top: 0;">3. High-Demand Regions in ${locationController.text}</h2>
    <p>Specific cities/regions with the best opportunities:</p>
    <ul style="padding-left: 20px;">
      <li><b>City 1:</b> Why it's a hub for this field</li>
      <li><b>City 2:</b> Emerging opportunities</li>
      <li><b>Remote Options:</b> Availability of remote work</li>
    </ul>
  </div>

  <!-- Salary Range -->
  <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <h2 style="color: #2980b9; margin-top: 0;">4. Expected Salary Range in ${locationController.text}</h2>
    <p>Current market rates (in local currency where applicable):</p>
    <ul style="padding-left: 20px;">
      <li><b>Entry-level (0-2 years):</b> X to Y PKR/month</li>
      <li><b>Mid-career (3-5 years):</b> A to B PKR/month</li>
      <li><b>Senior-level (5+ years):</b> C to D PKR/month</li>
      <li><b>Freelance/Contract:</b> E to F PKR/hour or project rates</li>
    </ul>
  </div>

  <!-- Detailed Learning Roadmap -->
  <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <h2 style="color: #2980b9; margin-top: 0;">5. Comprehensive Learning Roadmap</h2>
    
    <h3 style="color: #16a085;">Phase 1: Foundation (0-3 months)</h3>
    <ul style="padding-left: 20px;">
      <li><b>Core Concepts:</b> List fundamental concepts to learn</li>
      <li><b>Resources:</b> 
        <ul>
          <li>Book: "Book Title" by Author (specific to ${locationController.text} if possible)</li>
          <li>YouTube Channel: <a href="#">Channel Name</a> (focusing on beginner topics)</li>
          <li>Local Course: Institution/Course Name in ${locationController.text}</li>
        </ul>
      </li>
      <li><b>Projects:</b> Simple practice project ideas</li>
    </ul>
    
    <h3 style="color: #16a085;">Phase 2: Intermediate (3-6 months)</h3>
    <ul style="padding-left: 20px;">
      <li><b>Advanced Topics:</b> Next level skills to acquire</li>
      <li><b>Resources:</b>
        <ul>
          <li>Online Course: <a href="#">Course Name</a> (mention if available in local language)</li>
          <li>Community: Local meetups or online forums</li>
        </ul>
      </li>
      <li><b>Portfolio Building:</b> Types of projects to showcase skills</li>
    </ul>
    
    <h3 style="color: #16a085;">Phase 3: Advanced (6-12 months)</h3>
    <ul style="padding-left: 20px;">
      <li><b>Specialization Areas:</b> Specific niches within the field</li>
      <li><b>Certifications:</b> Industry-recognized certs relevant to ${locationController.text}</li>
      <li><b>Networking:</b> Local professional associations</li>
    </ul>
    
    <h3 style="color: #16a085;">Phase 4: Professional (1+ years)</h3>
    <ul style="padding-left: 20px;">
      <li><b>Career Advancement:</b> How to progress to senior roles</li>
      <li><b>Continuing Education:</b> Advanced degrees or certifications</li>
      <li><b>Mentorship:</b> How to find mentors in ${locationController.text}</li>
    </ul>
  </div>

  <!-- Learning Platforms -->
  <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <h2 style="color: #2980b9; margin-top: 0;">6. Recommended Learning Platforms</h2>
    <p>Curated list of resources with local alternatives where available:</p>
    <ul style="padding-left: 20px;">
      <li><b>Online Courses:</b>
        <ul>
          <li><a href="#">Coursera Specialization</a> (mention if financial aid available)</li>
          <li>Local platform like <a href="#">PlatformName</a> in ${locationController.text}</li>
        </ul>
      </li>
      <li><b>YouTube Channels:</b>
        <ul>
          <li><a href="#">Channel 1</a> - Focuses on practical skills</li>
          <li><a href="#">Channel 2</a> - Local content in your language</li>
        </ul>
      </li>
      <li><b>Books:</b> Include titles available in local bookstores</li>
      <li><b>Local Institutions:</b> Universities/training centers in ${locationController.text}</li>
    </ul>
  </div>

  <!-- Future Growth -->
  <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <h2 style="color: #2980b9; margin-top: 0;">7. Future Growth and Trends</h2>
    <p>Emerging opportunities in ${locationController.text}:</p>
    <ul style="padding-left: 20px;">
      <li>New technologies impacting the field</li>
      <li>Government policies supporting growth</li>
      <li>Global trends affecting local market</li>
    </ul>
  </div>

  <!-- Local Companies -->
  <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <h2 style="color: #2980b9; margin-top: 0;">8. Local Companies Hiring in ${locationController.text}</h2>
    <p>Top employers and how to approach them:</p>
    <ul style="padding-left: 20px;">
      <li><b>Multinationals:</b> List with locations</li>
      <li><b>Local Champions:</b> Growing companies in your region</li>
      <li><b>Startups:</b> Innovative local startups to watch</li>
      <li><b>How to Apply:</b> Local job portals and networking tips</li>
    </ul>
  </div>

  <!-- Final Advice -->
  <div style="background-color: #e3f2fd; padding: 20px; border-radius: 8px; border-left: 4px solid #2196f3; margin-bottom: 20px;">
    <h3 style="color: #0d47a1; margin-top: 0;">Your Next Steps</h3>
    <ol style="padding-left: 20px;">
      <li>Start with Phase 1 resources immediately</li>
      <li>Join local communities or online groups</li>
      <li>Set up informational interviews with professionals in ${locationController.text}</li>
      <li>Create a 3-month learning plan</li>
    </ol>
  </div>
</div>

Important Requirements:
1. All content must be specifically tailored to ${locationController.text} market conditions
2. Include real, verifiable resources (courses, books, YouTube channels) where possible
3. Provide actionable advice at each phase of the learning roadmap
4. Salary data should reflect current market rates in ${locationController.text}
5. Company recommendations should be real employers in the user's region
6. Maintain the exact HTML structure and styling provided
7. Do not include any placeholder text - every section must have complete information
8. Prioritize locally available resources when possible
''';

      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: AppConstants.geminiKey,
      );

      final response = await model.generateContent([Content.text(prompt)]);
      isLoading.value = false;

      String responseText = response.text ?? '''
    <div style="font-family: Arial; padding: 20px; color: #d63031; background-color: #ffeaa7; border-radius: 8px;">
      <p>No response received from Gemini. Please try again.</p>
    </div>
    ''';

      // Clean up response
      responseText = responseText
          .replaceAll('```html', '')
          .replaceAll('```', '')
          .trim();

      return responseText;
    } catch (e) {
      isLoading.value = false;
      debugPrint("Error generating career path: $e");
      return '''
    <div style="font-family: Arial; padding: 20px; color: #d63031; background-color: #ffeaa7; border-radius: 8px;">
      <p>We encountered an error generating your career path. Please try again later.</p>
      <p>Error details: ${e.toString()}</p>
    </div>
    ''';
    }
  }
}
