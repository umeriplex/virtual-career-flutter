import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:virtual_career/core/constant/app_constants.dart';
import 'package:virtual_career/core/managers/cache_manager.dart';
import 'package:virtual_career/core/theme/app_colors.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';
import 'package:virtual_career/core/utils/responsive.dart';
import 'package:virtual_career/core/utils/toast_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:virtual_career/features/resume_builder/repository/resume_builder_repository.dart';
import 'package:virtual_career/features/resume_builder/view/pdf_loading.dart';
import 'package:virtual_career/features/resume_builder/view/resume_viewer.dart';
import '../../../config/services/resume_service.dart';
import '../../../core/components/custom_image_view.dart';
import '../../../generated/assets.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/resumer_builder_controller.dart';
import '../model/resumer_model.dart';
import '../model/user_resume.dart';

class ResumeBuilderView extends StatefulWidget {
  const ResumeBuilderView({super.key});

  @override
  State<ResumeBuilderView> createState() => _ResumeBuilderViewState();
}

class _ResumeBuilderViewState extends State<ResumeBuilderView> {
  List<String> get resumeTemplates => [
      Assets.imagesTemp01,
      Assets.imagesTemp02,
      Assets.imagesTemp03,
      Assets.imagesTemp04,
      Assets.imagesTemp05,
      Assets.imagesTemp06,
      Assets.imagesTemp07,
      Assets.imagesTemp08,
      Assets.imagesTemp09,
      Assets.imagesTemp10,
      Assets.imagesTemp11,
      Assets.imagesTemp12,
      Assets.imagesTemp13,
      Assets.imagesTemp14,
      Assets.imagesTemp15,
      ];
  int selectedTemplate = 0;
  bool _isLoading = false;
  final TextEditingController _apiKeyController = TextEditingController();
  final ResumeBuilderController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    Responsive responsive = Responsive(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: responsive.responsivePadding(18.w, MediaQuery.of(context).padding.top + 6.h, 18.w, 10.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: responsive.responsivePadding(12.w, 10.h, 12.w, 10.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Your\nResume Journey',
                            style: AppTextStyles.headlineOpenSans.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          10.verticalSpace,
                          Text(
                            'Build a standout resume that reflects your goals and strengths.',
                            style: AppTextStyles.bodyOpenSans.copyWith(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    10.horizontalSpace,
                    InkWell(
                      onTap: () async {
                        _pickResume();
                        // await _generateAndOpenPdf(15, context, resume10);
                      },
                      child: Container(
                        padding: responsive.responsivePadding(10.w, 10.h, 10.w, 10.h),
                        decoration: BoxDecoration(
                          color: AppColor.buttonColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: _isLoading ? const CupertinoActivityIndicator(color: AppColor.black80,) : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.plus,
                                color: Colors.black,
                                size: 34.sp,
                              ),
                              5.verticalSpace,
                              Text(
                                'New Resume',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyOpenSans.copyWith(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              20.verticalSpace,
              Text(
                "Resume Templates",
                style: AppTextStyles.headlineOpenSans.copyWith(
                ),
              ),

              30.verticalSpace,
              SizedBox(
                width: double.maxFinite,
                height: 250.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      resumeTemplates.length,
                      (index) => GestureDetector(
                        onTap: () async {
                          setState(() {
                            selectedTemplate = index;
                          });
                        },
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          width: 180.w,
                          height: 240.h,
                          margin: EdgeInsets.only(right: 10.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: selectedTemplate == index ? AppColor.primaryColor : AppColor.white20.withValues(alpha: 0.09),
                              width: selectedTemplate == index ? 2.w : 1.w,
                            ),
                            image: DecorationImage(
                              image: AssetImage(resumeTemplates[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: selectedTemplate == index ?
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                _viewTemplate(index + 1, context, resume8);
                              },
                              child: AnimatedContainer(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: AppColor.black20.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  'View',
                                  style: AppTextStyles.titleOpenSans.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ) :
                          const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Obx((){
                if(controller.resumes.isNotEmpty){
                  List<UserResume> resumes = controller.resumes;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      30.verticalSpace,
                      Text(
                        "My Resumes",
                        style: AppTextStyles.headlineOpenSans,
                      ),
                      10.verticalSpace,
                      SizedBox(
                        width: double.maxFinite,
                        height: 250.h,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              resumes.length, (index) => GestureDetector(
                              onTap: () async {
                                Get.to(() => ResumeViewer(pdfUrl: resumes[index].pdfUrl,));
                              },
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                width: 180.w,
                                height: 240.h,
                                margin: EdgeInsets.only(right: 10.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: AppColor.white20.withValues(alpha: 0.09),
                                    width: 1.w,
                                  ),
                                ),
                                child: UltimateCachedNetworkImage(imageUrl: resumes[index].thumbnailUrl)
                              ),
                            ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }else{
                  return const SizedBox.shrink();
                }
              }),


            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateAndOpenPdf(int templateNumber, BuildContext context, Resume resume) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      showSuccessMessage("Generating PDF...");

      final file = await PdfResumeService.generateResume(resume, templateNumber);

      Navigator.of(Get.context!).pop();

      await Future.delayed(const Duration(milliseconds: 500));

      Get.to(() => ResumeViewer(file: file, isNew: true, resume: resume,));
      // await PdfResumeService.openFile(file);
    } catch (e) {
      showErrorMessage("Failed to generate PDF: $e");
    }
  }

  Future<void> _viewTemplate(int templateNumber, BuildContext context, Resume resume) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      showSuccessMessage("Generating PDF...");

      final file = await PdfResumeService.generateResume(resume, templateNumber);

      await Future.delayed(const Duration(milliseconds: 500));

      Get.to(() => ResumeViewer(file: file, isNew: false, resume: resume,));
      // await PdfResumeService.openFile(file);
    } catch (e) {
      showErrorMessage("Failed to generate PDF: $e");
    }
  }


  Future<void> _pickResume() async {
    try{
      setState(() => _isLoading = true );
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        showErrorMessage('No file selected');
        return;
      }

      if (result.files.single.extension != 'pdf') {
        showErrorMessage('Please select a valid PDF file');
        return;
      }

      File file = File(result.files.single.path!);


      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => const PdfLoadingDialog(message: "Take a moment to analyze your resume..."),
      );

      await _parseAndGenerateResume(file);

    }catch(e){
      debugPrint("Error picking file: $e");
      showErrorMessage("Something went wrong, please try again.");
    }finally{
      setState(() => _isLoading = false );
    }
  }

  Future<String> _extractTextFromPdf(File file) async {
    String text = "";
    try {
      text = await ReadPdfText.getPDFtext(file.path);
    } catch (e) {
      throw Exception("Error extracting text from PDF: $e");
    }
    return text;
  }

  Future<void> _parseAndGenerateResume(File file) async {
    try {
      // Extract text from PDF
      final resumeText = await _extractTextFromPdf(file);

      // Initialize the Gemini model
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: "AIzaSyAamZnC3rXzQKNLwC_8ju0p-ScLylh9JEE",
      );

      // Create a prompt for Gemini
      String prompt = '''
You are a resume parser. The user will provide raw resume text like [$resumeText].

**Your task:**
- Analyze the text and try to extract structured resume data.
- If the text appears to be a valid resume, extract the data and return only valid JSON in the format below.
- If the text is not a resume, is empty, or is unreadable, return this instead:
  { "error": "Resume data not found or the file is invalid." }

**Output Rules:**
- Always return ONLY valid JSON, nothing else.
- Do not explain anything.
- Do not include formatting outside of the JSON block.

**Expected Format (only if resume is valid):**

{
  "heading": {
    "name": "",
    "position": "",
    "avatar": ""
  },
  "summary": "",
  "contact": [
    {
      "type": "email",
      "value": ""
    }
  ],
  "experience": [
    {
      "company": "",
      "position": "",
      "duration": "",
      "location": "",
      "responsibilities": []
    }
  ],
  "education": [
    {
      "institution": "",
      "degree": "",
      "year": ""
    }
  ],
  "skills": [
    {
      "category": "",
      "items": []
    }
  ],
  "projects": [
    {
      "name": "",
      "description": "",
      "technologies": []
    }
  ],
  "certifications": [
    {
      "name": "",
      "year": ""
    }
  ],
  "languages": [
    {
      "name": "",
      "proficiency": ""
    }
  ]
}
''';


      // Get the response from Gemini
      final content = Content.text(prompt);
      final response = await model.generateContent([content]);
      var responseText = response.text ?? '';

      // Clean up the response
      if (responseText.startsWith('```json') || responseText.startsWith('```')) {
        responseText = responseText.substring(7);
      }
      if (responseText.endsWith('')) {
        responseText = responseText.substring(0, responseText.length - 3);
      }
      debugPrint('Gemini response: $responseText');

      // Parse the JSON response
      final jsonResponse = jsonDecode(responseText);

      if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('error')) {
        throw Exception(jsonResponse['error']);
      }


      final parsedResume = Resume.fromJson(jsonResponse);

      debugPrint('Parsed Resume: ${parsedResume.toJson()}');

      print("Selected template: ${selectedTemplate+1}");

      await _generateAndOpenPdf(selectedTemplate+1, context, parsedResume);

    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

}

// Resume 1: Complete resume with all fields
final resume1 = Resume(
  heading: Heading(
    name: "John Doe",
    position: "Senior Flutter Developer",
    avatar: AppConstants.placeHolderImage,
  ),
  summary: "Experienced mobile developer with 5+ years in Flutter and native Android development.",
  contact: [
    ContactItem(type: "email", value: "john.doe@example.com"),
    ContactItem(type: "phone", value: "+1 (555) 123-4567"),
    ContactItem(type: "linkedin", value: "linkedin.com/in/johndoe"),
  ],
  experience: [
    ExperienceItem(
      company: "Tech Solutions Inc.",
      position: "Senior Flutter Developer",
      duration: "2020 - Present",
      location: "San Francisco, CA",
      responsibilities: [
        "Lead mobile app development team",
        "Architected scalable Flutter applications",
        "Mentored junior developers",
      ],
    ),
  ],
  education: [
    EducationItem(
      institution: "Stanford University",
      degree: "Master of Computer Science",
      year: "2018",
    ),
  ],
  skills: [
    SkillCategory(
      category: "Mobile Development",
      items: ["Flutter", "Dart", "Android", "iOS"],
    ),
  ],
  projects: [
    ProjectItem(
      name: "E-Commerce App",
      description: "Built a cross-platform e-commerce app with 100k+ downloads",
      technologies: ["Flutter", "Firebase", "BLoC"],
    ),
  ],
  certifications: [
    CertificationItem(
      name: "Google Certified Mobile Developer",
      year: "2020",
    ),
  ],
  languages: [
    LanguageItem(name: "English", proficiency: "Native"),
    LanguageItem(name: "Spanish", proficiency: "Intermediate"),
  ],
);

// Resume 2: Minimal resume with only essential fields
final resume2 = Resume(
  heading: Heading(
    name: "Sarah Smith",
    position: "UX/UI Designer",
  ),
  summary: "Creative designer focused on user-centered design principles.",
  contact: [
    ContactItem(type: "email", value: "sarah.smith@example.com"),
  ],
  experience: [
    ExperienceItem(
      company: "Design Hub",
      position: "Lead Designer",
      duration: "2019 - Present",
    ),
  ],
  education: null,
  skills: [
    SkillCategory(
      category: "Design Tools",
      items: ["Figma", "Adobe XD", "Sketch"],
    ),
  ],
  projects: null,
  certifications: null,
  languages: null,
);

// Resume 3: Academic-focused resume
final resume3 = Resume(
  heading: Heading(
    name: "Dr. Michael Johnson",
    position: "Research Scientist",
    avatar: null,
  ),
  summary: null,
  contact: [
    ContactItem(type: "email", value: "m.johnson@university.edu"),
    ContactItem(type: "phone", value: "+1 (555) 987-6543"),
  ],
  experience: null,
  education: [
    EducationItem(
      institution: "MIT",
      degree: "PhD in Computer Science",
      year: "2015",
    ),
    EducationItem(
      institution: "Harvard University",
      degree: "Master of Science",
      year: "2010",
    ),
  ],
  skills: [
    SkillCategory(
      category: "Research",
      items: ["Machine Learning", "Data Analysis", "Python"],
    ),
  ],
  projects: [
    ProjectItem(
      name: "AI for Medical Diagnosis",
      description: "Developed ML models for early disease detection",
      technologies: ["Python", "TensorFlow", "PyTorch"],
    ),
  ],
  certifications: [
    CertificationItem(name: "AWS Certified AI Specialist", year: "2021"),
  ],
  languages: [
    LanguageItem(name: "English", proficiency: "Fluent"),
    LanguageItem(name: "French", proficiency: "Advanced"),
  ],
);

// Resume 4: Fresh graduate with limited experience
final resume4 = Resume(
  heading: Heading(
    name: "Alex Chen",
    position: "Junior Software Engineer",
  ),
  summary: "Recent computer science graduate passionate about backend development.",
  contact: [
    ContactItem(type: "email", value: "alex.chen@example.com"),
    ContactItem(type: "github", value: "github.com/alexchen"),
  ],
  experience: [
    ExperienceItem(
      company: "University Lab",
      position: "Research Assistant",
      duration: "2021 - 2022",
      responsibilities: [
        "Assisted in database optimization research",
        "Wrote Python scripts for data processing",
      ],
    ),
  ],
  education: [
    EducationItem(
      institution: "University of Washington",
      degree: "BS in Computer Science",
      year: "2022",
    ),
  ],
  skills: [
    SkillCategory(
      category: "Programming",
      items: ["Python", "Java", "SQL"],
    ),
  ],
  projects: [
    ProjectItem(
      name: "Library Management System",
      description: "Built a database system for university library",
      technologies: ["Java", "MySQL"],
    ),
  ],
  certifications: null,
  languages: [
    LanguageItem(name: "English", proficiency: "Fluent"),
    LanguageItem(name: "Mandarin", proficiency: "Native"),
  ],
);

// Resume 5: Career changer with non-tech background
final resume5 = Resume(
  heading: Heading(
    name: "Maria Garcia",
    position: "Web Development Student",
  ),
  summary: "Former marketing professional transitioning to web development.",
  contact: [
    ContactItem(type: "email", value: "maria.garcia@example.com"),
  ],
  experience: [
    ExperienceItem(
      company: "Digital Marketing Co.",
      position: "Marketing Manager",
      duration: "2015 - 2022",
    ),
  ],
  education: [
    EducationItem(
      institution: "Coding Bootcamp",
      degree: "Full Stack Web Development",
      year: "2022",
    ),
    EducationItem(
      institution: "NYU",
      degree: "BA in Marketing",
      year: "2015",
    ),
  ],
  skills: [
    SkillCategory(
      category: "Web Development",
      items: ["HTML", "CSS", "JavaScript"],
    ),
    SkillCategory(
      category: "Marketing",
      items: ["SEO", "Content Strategy", "Social Media"],
    ),
  ],
  projects: [
    ProjectItem(
      name: "Portfolio Website",
      description: "Built personal portfolio with responsive design",
      technologies: ["HTML", "CSS", "JavaScript"],
    ),
  ],
  certifications: [
    CertificationItem(name: "Google Analytics Certified", year: "2020"),
  ],
  languages: [
    LanguageItem(name: "English", proficiency: "Fluent"),
    LanguageItem(name: "Spanish", proficiency: "Native"),
  ],
);

final resume6 = Resume(
  heading: Heading(
    name: "Emily Chen",
    position: "Senior UX Design Lead",
    avatar: AppConstants.placeHolderImage,
  ),
  summary: "Human-centered design leader with 8+ years of experience creating intuitive digital products. Passionate about bridging user needs with business goals through research-driven design.",
  contact: [
    ContactItem(type: "email", value: "emily.chen@example.com"),
    ContactItem(type: "phone", value: "+1 (555) 321-4567"),
    ContactItem(type: "portfolio", value: "emilychen.design"),
    ContactItem(type: "linkedin", value: "linkedin.com/in/emilychenux"),
  ],
  experience: [
    ExperienceItem(
      company: "Digital Product Studio",
      position: "UX Design Lead",
      duration: "2020 - Present",
      location: "San Francisco, CA",
      responsibilities: [
        "Lead UX strategy for Fortune 500 clients across healthcare and fintech",
        "Manage team of 5 designers and researchers",
        "Established design system used by 50+ product teams",
        "Increased user satisfaction scores by 35% through research insights",
      ],
    ),
    ExperienceItem(
      company: "Tech Startup Inc.",
      position: "Senior UX Designer",
      duration: "2017 - 2020",
      location: "Austin, TX",
      responsibilities: [
        "Designed core product experience for SaaS platform",
        "Conducted 100+ user interviews and usability tests",
        "Created design system that reduced development time by 40%",
        "Collaborated with PMs and engineers in agile environment",
      ],
    ),
    ExperienceItem(
      company: "Creative Agency",
      position: "UX/UI Designer",
      duration: "2015 - 2017",
      location: "Chicago, IL",
      responsibilities: [
        "Designed websites and mobile apps for 20+ clients",
        "Created wireframes, prototypes, and high-fidelity mockups",
        "Presented design concepts to stakeholders",
      ],
    ),
  ],
  education: [
    EducationItem(
      institution: "School of Visual Arts",
      degree: "MFA in Interaction Design",
      year: "2015",
    ),
    EducationItem(
      institution: "University of Michigan",
      degree: "BS in Cognitive Science",
      year: "2013",
    ),
  ],
  skills: [
    SkillCategory(
      category: "Design",
      items: ["User Research", "Information Architecture", "Wireframing", "Prototyping", "UI Design"],
    ),
    SkillCategory(
      category: "Tools",
      items: ["Figma", "Sketch", "Adobe XD", "InVision", "Miro"],
    ),
    SkillCategory(
      category: "Leadership",
      items: ["Design Thinking", "Workshop Facilitation", "Mentoring", "Cross-functional Collaboration"],
    ),
  ],
  projects: [
    ProjectItem(
      name: "Healthcare Portal Redesign",
      description: "Redesigned patient portal resulting in 50% increase in engagement",
      technologies: ["Figma", "UserTesting", "Design System"],
    ),
    ProjectItem(
      name: "Mobile Banking App",
      description: "Led end-to-end design for award-winning banking app",
      technologies: ["iOS/Android Patterns", "Accessibility", "Micro-interactions"],
    ),
  ],
  certifications: [
    CertificationItem(name: "NN/g UX Certification", year: "2019"),
    CertificationItem(name: "IDF Design Leadership", year: "2021"),
  ],
  languages: [
    LanguageItem(name: "English", proficiency: "Native"),
    LanguageItem(name: "Mandarin", proficiency: "Fluent"),
  ],
);

final resume7 = Resume(
  heading: Heading(
    name: "Dr. Raj Patel",
    position: "Senior Data Scientist",
    avatar: AppConstants.placeHolderImage,
  ),
  summary: "PhD Data Scientist with 6+ years of experience applying machine learning to solve real-world problems. Published researcher with expertise in NLP and computer vision.",
  contact: [
    ContactItem(type: "email", value: "raj.patel@example.com"),
    ContactItem(type: "phone", value: "+1 (555) 987-1234"),
    ContactItem(type: "github", value: "github.com/drrajpatel"),
    ContactItem(type: "scholar", value: "scholar.google.com/rajpatel"),
  ],
  experience: [
    ExperienceItem(
      company: "AI Research Lab",
      position: "Lead Data Scientist",
      duration: "2020 - Present",
      location: "Boston, MA",
      responsibilities: [
        "Develop novel NLP algorithms for document understanding",
        "Lead team of 4 data scientists and engineers",
        "Published 5 peer-reviewed papers in top conferences",
        "Built production ML pipelines serving 1M+ requests/day",
      ],
    ),
    ExperienceItem(
      company: "University Research Center",
      position: "Postdoctoral Researcher",
      duration: "2018 - 2020",
      location: "Cambridge, MA",
      responsibilities: [
        "Conducted research on multimodal machine learning",
        "Developed novel computer vision architectures",
        "Mentored graduate students",
        "Secured 500K in research funding",
      ],
    ),
    ExperienceItem(
      company: "Tech Startup",
      position: "Data Science Intern",
      duration: "Summer 2017",
      location: "New York, NY",
      responsibilities: [
        "Built recommendation system increasing engagement by 25%",
        "Created data visualization dashboard for business metrics",
        "Cleaned and processed large datasets",
      ],
    ),
  ],
  education: [
    EducationItem(
      institution: "MIT",
      degree: "PhD in Computer Science",
      year: "2018",
    ),
    EducationItem(
      institution: "Stanford University",
      degree: "MS in Artificial Intelligence",
      year: "2013",
    ),
    EducationItem(
      institution: "IIT Bombay",
      degree: "BTech in Computer Engineering",
      year: "2011",
    ),
  ],
  skills: [
    SkillCategory(
      category: "Machine Learning",
      items: ["Deep Learning", "Natural Language Processing", "Computer Vision", "Recommender Systems"],
    ),
    SkillCategory(
      category: "Programming",
      items: ["Python", "PyTorch", "TensorFlow", "SQL", "Spark"],
    ),
    SkillCategory(
      category: "Research",
      items: ["Experimental Design", "Statistical Analysis", "Academic Writing", "Peer Review"],
    ),
  ],
  projects: [
    ProjectItem(
      name: "Document Understanding System",
      description: "Developed state-of-the-art system for extracting information from documents",
      technologies: ["Transformer Models", "OCR", "Information Extraction"],
    ),
    ProjectItem(
      name: "Multimodal Video Analysis",
      description: "Research project combining visual, audio and text modalities",
      technologies: ["Neural Networks", "Attention Mechanisms", "Self-supervised Learning"],
    ),
  ],
  certifications: [
    CertificationItem(name: "AWS Certified Machine Learning", year: "2021"),
  ],
  languages: [
    LanguageItem(name: "English", proficiency: "Fluent"),
    LanguageItem(name: "Hindi", proficiency: "Native"),
    LanguageItem(name: "Spanish", proficiency: "Intermediate"),
  ],
);

final resume8 = Resume(
  heading: Heading(
    name: "Jamal Williams",
    position: "Full-Stack Engineer",
    avatar: AppConstants.placeHolderImage,
  ),
  summary: "Versatile full-stack developer with 5 years of experience building web applications from concept to production. Comfortable across the stack with focus on React and Node.js ecosystems.",
  contact: [
    ContactItem(type: "email", value: "jamal.williams@example.com"),
    ContactItem(type: "phone", value: "+1 (555) 456-7890"),
    ContactItem(type: "github", value: "github.com/jamalw"),
    ContactItem(type: "website", value: "jamalw.dev"),
  ],
  experience: [
    ExperienceItem(
      company: "StartUp Ventures",
      position: "Senior Software Engineer",
      duration: "2021 - Present",
      location: "Remote",
      responsibilities: [
        "Lead development of core product features",
        "Architected microservices backend",
        "Implemented real-time collaboration features",
        "Mentored junior developers",
      ],
    ),
    ExperienceItem(
      company: "Digital Agency",
      position: "Full-Stack Developer",
      duration: "2019 - 2021",
      location: "Chicago, IL",
      responsibilities: [
        "Built custom CMS solutions for clients",
        "Developed e-commerce platforms",
        "Optimized web performance (improved Lighthouse scores by 40%)",
        "Implemented CI/CD pipelines",
      ],
    ),
    ExperienceItem(
      company: "Freelance",
      position: "Web Developer",
      duration: "2017 - 2019",
      location: "Chicago, IL",
      responsibilities: [
        "Developed websites for small businesses",
        "Created custom WordPress themes",
        "Provided technical consulting",
      ],
    ),
  ],
  education: [
    EducationItem(
      institution: "CodePath",
      degree: "Advanced Web Development",
      year: "2019",
    ),
    EducationItem(
      institution: "University of Illinois",
      degree: "BS in Information Sciences",
      year: "2017",
    ),
  ],
  skills: [
    SkillCategory(
      category: "Frontend",
      items: ["React", "TypeScript", "Next.js", "GraphQL", "Tailwind CSS"],
    ),
    SkillCategory(
      category: "Backend",
      items: ["Node.js", "Express", "NestJS", "PostgreSQL", "MongoDB"],
    ),
    SkillCategory(
      category: "DevOps",
      items: ["Docker", "AWS", "GitHub Actions", "Terraform", "Kubernetes"],
    ),
  ],
  projects: [
    ProjectItem(
      name: "Collaborative Whiteboard",
      description: "Real-time collaborative whiteboard with 10K+ users",
      technologies: ["WebSockets", "Canvas API", "React", "Node.js"],
    ),
    ProjectItem(
      name: "Open Source Library",
      description: "Popular React component library with 5K+ GitHub stars",
      technologies: ["React", "Storybook", "Jest", "Rollup"],
    ),
  ],
  certifications: [
    CertificationItem(name: "Google Cloud Associate Engineer", year: "2022"),
  ],
  languages: [
    LanguageItem(name: "English", proficiency: "Native"),
  ],
);

final resume9 = Resume(
  heading: Heading(
    name: "Olivia Martinez",
    position: "Senior Financial Analyst",
    avatar: AppConstants.placeHolderImage,
  ),
  summary: "CFA charterholder with 7 years of experience in financial analysis and data-driven decision making. Combining traditional finance expertise with modern data analytics techniques.",
  contact: [
    ContactItem(type: "email", value: "olivia.martinez@example.com"),
    ContactItem(type: "phone", value: "+1 (555) 789-1234"),
    ContactItem(type: "linkedin", value: "linkedin.com/in/oliviamfinance"),
  ],
  experience: [
    ExperienceItem(
      company: "Global Investment Firm",
      position: "Senior Financial Analyst",
      duration: "2019 - Present",
      location: "New York, NY",
      responsibilities: [
        "Lead team analyzing 2B investment portfolio",
        "Developed predictive models for market trends",
        "Automated reporting saving 20 hours/week",
        "Present findings to executive leadership",
      ],
    ),
    ExperienceItem(
      company: "Big 4 Accounting Firm",
      position: "Financial Consultant",
      duration: "2016 - 2019",
      location: "New York, NY",
      responsibilities: [
        "Advised Fortune 500 clients on financial strategy",
        "Built financial models for M&A transactions",
        "Conducted due diligence for acquisitions",
      ],
    ),
    ExperienceItem(
      company: "Investment Bank",
      position: "Analyst",
      duration: "2014 - 2016",
      location: "Chicago, IL",
      responsibilities: [
        "Prepared pitch books and financial analyses",
        "Supported senior bankers on deals",
        "Built DCF and LBO models",
      ],
    ),
  ],
  education: [
    EducationItem(
      institution: "University of Chicago",
      degree: "MBA",
      year: "2018",
    ),
    EducationItem(
      institution: "Northwestern University",
      degree: "BS in Economics",
      year: "2014",
    ),
  ],
  skills: [
    SkillCategory(
      category: "Finance",
      items: ["Financial Modeling", "Valuation", "Portfolio Analysis", "Risk Management"],
    ),
    SkillCategory(
      category: "Analytics",
      items: ["Python", "SQL", "Tableau", "Power BI", "Excel VBA"],
    ),
    SkillCategory(
      category: "Leadership",
      items: ["Team Management", "Stakeholder Communication", "Project Leadership"],
    ),
  ],
  projects: [
    ProjectItem(
      name: "Portfolio Optimization Tool",
      description: "Built tool optimizing asset allocation using ML techniques",
      technologies: ["Python", "Pandas", "Scikit-learn"],
    ),
    ProjectItem(
      name: "Automated Reporting System",
      description: "Developed system automating monthly financial reports",
      technologies: ["SQL", "Power BI", "Python"],
    ),
  ],
  certifications: [
    CertificationItem(name: "Chartered Financial Analyst (CFA)", year: "2017"),
    CertificationItem(name: "Financial Risk Manager (FRM)", year: "2019"),
  ],
  languages: [
    LanguageItem(name: "English", proficiency: "Native"),
    LanguageItem(name: "Spanish", proficiency: "Fluent"),
    LanguageItem(name: "French", proficiency: "Intermediate"),
  ],
);

final resume10 = Resume(
  heading: Heading(
    name: "Daniel Brown",
    position: "Cybersecurity Architect",
    avatar: AppConstants.placeHolderImage,
  ),
  summary: "Security professional with 10 years of experience protecting critical infrastructure. Specialized in cloud security and threat intelligence with government clearance.",
  contact: [
    ContactItem(type: "email", value: "daniel.brown@example.com"),
    ContactItem(type: "phone", value: "+1 (555) 321-7890"),
    ContactItem(type: "website", value: "securitybydaniel.com"),
  ],
  experience: [
    ExperienceItem(
      company: "Federal Government",
      position: "Senior Cybersecurity Specialist",
      duration: "2018 - Present",
      location: "Washington, DC",
      responsibilities: [
        "Lead security architecture for critical systems",
        "Develop threat detection capabilities",
        "Conduct penetration testing and red team exercises",
        "Advise on security policy and standards",
      ],
    ),
    ExperienceItem(
      company: "Defense Contractor",
      position: "Security Engineer",
      duration: "2015 - 2018",
      location: "Arlington, VA",
      responsibilities: [
        "Implemented zero trust architecture",
        "Managed SIEM and security monitoring",
        "Conducted security assessments",
        "Responded to security incidents",
      ],
    ),
    ExperienceItem(
      company: "Tech Company",
      position: "Security Analyst",
      duration: "2012 - 2015",
      location: "Reston, VA",
      responsibilities: [
        "Monitored security alerts and events",
        "Investigated potential threats",
        "Implemented security controls",
      ],
    ),
  ],
  education: [
    EducationItem(
      institution: "Georgia Tech",
      degree: "MS in Cybersecurity",
      year: "2015",
    ),
    EducationItem(
      institution: "Virginia Tech",
      degree: "BS in Computer Science",
      year: "2012",
    ),
  ],
  skills: [
    SkillCategory(
      category: "Security",
      items: ["Cloud Security", "Threat Intelligence", "Penetration Testing", "Incident Response"],
    ),
    SkillCategory(
      category: "Technical",
      items: ["AWS/GCP Security", "SIEM", "Firewalls", "IDS/IPS", "Python"],
    ),
    SkillCategory(
      category: "Compliance",
      items: ["NIST", "ISO 27001", "FedRAMP", "SOC 2"],
    ),
  ],
  projects: [
    ProjectItem(
      name: "Cloud Security Framework",
      description: "Developed security framework adopted across government agencies",
      technologies: ["AWS", "Terraform", "Security Controls"],
    ),
    ProjectItem(
      name: "Threat Intelligence Platform",
      description: "Built platform aggregating and analyzing threat data",
      technologies: ["Python", "Elasticsearch", "Machine Learning"],
    ),
  ],
  certifications: [
    CertificationItem(name: "CISSP", year: "2017"),
    CertificationItem(name: "CCSP", year: "2019"),
    CertificationItem(name: "CEH", year: "2016"),
  ],
  languages: [
    LanguageItem(name: "English", proficiency: "Native"),
  ],
);

final resume11 = Resume(
  heading: Heading(
    name: "Ava Chen",
    position: "Frontend Developer",
    avatar: AppConstants.placeHolderImage,
  ),
  summary: "Creative frontend developer with a passion for UI/UX.",
  contact: [
    ContactItem(type: "email", value: "ava.chen@example.com"),
  ],
  experience: [
    ExperienceItem(
      company: "Design Studio",
      position: "Frontend Engineer",
      duration: "2020 - Present",
      location: null,
      responsibilities: ["Developed accessible UI components", "Worked closely with designers"],
    ),
  ],
  education: null,
  skills: [
    SkillCategory(category: "Frontend", items: ["Vue.js", "HTML", "CSS", "JavaScript"]),
  ],
  projects: null,
  certifications: null,
  languages: null,
);

final resume12 = Resume(
  heading: Heading(
    name: "Marcus Lee",
    position: null,
    avatar: null,
  ),
  summary: null,
  contact: null,
  experience: null,
  education: [
    EducationItem(institution: "MIT", degree: "BSc Computer Science", year: "2016"),
  ],
  skills: null,
  projects: null,
  certifications: null,
  languages: [
    LanguageItem(name: "English", proficiency: "Fluent"),
    LanguageItem(name: "Mandarin", proficiency: "Intermediate"),
  ],
);

final resume13 = Resume(
  heading: Heading(name: "Sara Ibrahim", position: "Backend Developer", avatar: null),
  summary: "Detail-oriented backend developer with experience in Go and Node.js.",
  contact: [
    ContactItem(type: "github", value: "github.com/sarai"),
    ContactItem(type: "website", value: "saradev.io"),
  ],
  experience: [
    ExperienceItem(
      company: "CloudTech",
      position: "Backend Developer",
      duration: "2018 - 2022",
      location: "San Francisco, CA",
      responsibilities: null,
    ),
  ],
  education: null,
  skills: [
    SkillCategory(category: "Backend", items: ["Go", "Node.js", "Redis", "PostgreSQL"]),
  ],
  projects: null,
  certifications: null,
  languages: null,
);

final resume14 = Resume(
  heading: Heading(name: "Luis Ramirez", position: "DevOps Engineer", avatar: null),
  summary: null,
  contact: null,
  experience: [
    ExperienceItem(
      company: "InfraCorp",
      position: "DevOps Specialist",
      duration: "2021 - Present",
      location: "Austin, TX",
      responsibilities: ["Deployed Kubernetes clusters", "Maintained CI/CD pipelines"],
    ),
  ],
  education: null,
  skills: [
    SkillCategory(category: "DevOps", items: ["Docker", "Ansible", "Kubernetes", "Azure"]),
  ],
  projects: null,
  certifications: [
    CertificationItem(name: "AWS Certified DevOps Engineer", year: "2021"),
  ],
  languages: null,
);

final resume15 = Resume(
  heading: Heading(name: "Nina Patel", position: null, avatar: AppConstants.placeHolderImage),
  summary: "Software engineer passionate about education technology.",
  contact: null,
  experience: null,
  education: [
    EducationItem(institution: "Stanford University", degree: "MS in Education Technology", year: "2020"),
  ],
  skills: null,
  projects: [
    ProjectItem(
      name: "LearnBuddy",
      description: "Interactive platform for personalized student learning",
      technologies: ["React", "Firebase", "TypeScript"],
    ),
  ],
  certifications: null,
  languages: null,
);

final resume16 = Resume(
  heading: Heading(name: "Tomoko Yamada", position: "Mobile Developer", avatar: null),
  summary: null,
  contact: [
    ContactItem(type: "email", value: "tomoko.y@example.com"),
  ],
  experience: null,
  education: null,
  skills: [
    SkillCategory(category: "Mobile", items: ["Flutter", "Swift", "Kotlin"]),
  ],
  projects: [
    ProjectItem(
      name: "FitTrack",
      description: "Fitness tracking app with wearable integration",
      technologies: ["Flutter", "Bluetooth", "Firebase"],
    ),
  ],
  certifications: null,
  languages: [
    LanguageItem(name: "Japanese", proficiency: "Native"),
    LanguageItem(name: "English", proficiency: "Professional"),
  ],
);

final resume17 = Resume(
  heading: null,
  summary: null,
  contact: null,
  experience: null,
  education: null,
  skills: null,
  projects: null,
  certifications: null,
  languages: null,
);

final resume18 = Resume(
  heading: Heading(
    name: "Sophia Turner",
    position: "Principal Software Architect",
    avatar: AppConstants.placeHolderImage,
  ),
  summary: "Seasoned architect with 15+ years of experience leading cross-functional teams to deliver scalable enterprise solutions in finance and healthcare domains.",
  contact: [
    ContactItem(type: "email", value: "sophia.turner@techdomain.com"),
    ContactItem(type: "linkedin", value: "linkedin.com/in/sophiaturner"),
  ],
  experience: [
    ExperienceItem(
      company: "FinTrust Systems",
      position: "Principal Architect",
      duration: "2018 - Present",
      location: "New York, NY",
      responsibilities: [
        "Defined microservices architecture across 10+ departments",
        "Migrated legacy monolith to cloud-native infrastructure",
        "Led architecture reviews and code quality enforcement",
        "Guided teams on using Kubernetes, gRPC, and service mesh",
      ],
    ),
    ExperienceItem(
      company: "MediSoft Solutions",
      position: "Senior Software Engineer",
      duration: "2012 - 2018",
      location: "Boston, MA",
      responsibilities: [
        "Built HIPAA-compliant health record systems",
        "Designed secure data ingestion pipelines",
        "Managed backend development with Java Spring Boot",
      ],
    ),
  ],
  education: [
    EducationItem(institution: "MIT", degree: "MS in Computer Science", year: "2010"),
    EducationItem(institution: "MIT", degree: "BS in Software Engineering", year: "2008"),
  ],
  skills: [
    SkillCategory(category: "Architecture", items: ["Microservices", "Event-Driven Systems", "Distributed Systems"]),
    SkillCategory(category: "Cloud", items: ["AWS", "Azure", "Kubernetes", "Terraform"]),
    SkillCategory(category: "Programming", items: ["Java", "Go", "Python", "C++"]),
  ],
  projects: [
    ProjectItem(
      name: "Insurance Claims Engine",
      description: "Processed 10M+ monthly claims across 5 insurance partners",
      technologies: ["Kafka", "Spring Boot", "MongoDB", "Redis"],
    ),
  ],
  certifications: [
    CertificationItem(name: "AWS Certified Solutions Architect – Professional", year: "2021"),
    CertificationItem(name: "TOGAF 9 Certified", year: "2020"),
  ],
  languages: [LanguageItem(name: "English", proficiency: "Native")],
);

final resume19 = Resume(
  heading: Heading(
    name: "Daniel Zhang",
    position: "Staff Engineer - Infrastructure",
    avatar: null,
  ),
  summary: "Staff engineer specializing in building secure and performant infrastructure platforms supporting multi-tenant SaaS products.",
  contact: [
    ContactItem(type: "email", value: "daniel.zhang@cloudhub.io"),
    ContactItem(type: "github", value: "github.com/danielz-dev"),
  ],
  experience: [
    ExperienceItem(
      company: "CloudHub Inc.",
      position: "Staff Engineer",
      duration: "2020 - Present",
      location: "Remote",
      responsibilities: [
        "Designed internal PaaS using Kubernetes + Istio",
        "Created reusable CI/CD templates across teams",
        "Reduced infra cost by 30% via autoscaling + spot usage",
      ],
    ),
    ExperienceItem(
      company: "DataForge Ltd.",
      position: "Site Reliability Engineer",
      duration: "2015 - 2020",
      location: "San Francisco, CA",
      responsibilities: [
        "Managed 500+ containers in production",
        "Built observability stack using Prometheus + Grafana",
        "Implemented security hardening (CIS Benchmarks)",
      ],
    ),
  ],
  education: [
    EducationItem(institution: "Stanford University", degree: "BS in Computer Systems Engineering", year: "2014"),
  ],
  skills: [
    SkillCategory(category: "DevOps", items: ["Kubernetes", "Helm", "Ansible", "Vault"]),
    SkillCategory(category: "Observability", items: ["Grafana", "ELK Stack", "Prometheus"]),
  ],
  projects: null,
  certifications: [
    CertificationItem(name: "CKA (Certified Kubernetes Administrator)", year: "2019"),
  ],
  languages: [
    LanguageItem(name: "English", proficiency: "Fluent"),
    LanguageItem(name: "Mandarin", proficiency: "Native"),
  ],
);

final resume20 = Resume(
  heading: Heading(
    name: "Emily Rivera",
    position: "Senior Product Engineer",
    avatar: null,
  ),
  summary: "Product-focused engineer blending UX with robust engineering to build delightful user experiences. Expert in full-stack JS with an eye for design.",
  contact: [
    ContactItem(type: "email", value: "emily.rivera@creativelabs.io"),
    ContactItem(type: "portfolio", value: "emilyrivera.dev"),
  ],
  experience: [
    ExperienceItem(
      company: "Creative Labs",
      position: "Senior Product Engineer",
      duration: "2020 - Present",
      location: "Los Angeles, CA",
      responsibilities: [
        "Built highly interactive dashboards with React + D3.js",
        "Redesigned UX flows to improve user engagement by 50%",
        "Led accessibility efforts and WCAG compliance",
      ],
    ),
  ],
  education: [
    EducationItem(institution: "UC Berkeley", degree: "BS in Cognitive Science", year: "2016"),
  ],
  skills: [
    SkillCategory(category: "Frontend", items: ["React", "TypeScript", "Styled Components"]),
    SkillCategory(category: "Backend", items: ["Node.js", "GraphQL", "Firebase"]),
    SkillCategory(category: "Design", items: ["Figma", "UX Research"]),
  ],
  projects: [
    ProjectItem(
      name: "Design System",
      description: "Reusable component library used across 8 internal products",
      technologies: ["React", "Storybook", "Chromatic"],
    ),
  ],
  certifications: null,
  languages: [LanguageItem(name: "English", proficiency: "Native")],
);

final resume21 = Resume(
  heading: Heading(
    name: "Mohammed Khan",
    position: "Lead AI Engineer",
    avatar: AppConstants.placeHolderImage,
  ),
  summary: "AI specialist with deep experience in NLP, LLM fine-tuning, and MLOps. Delivered ML pipelines for products used by millions.",
  contact: [
    ContactItem(type: "email", value: "m.khan@mlcloud.ai"),
    ContactItem(type: "website", value: "mohammedkhan.ai"),
  ],
  experience: [
    ExperienceItem(
      company: "MLCloud AI",
      position: "Lead AI Engineer",
      duration: "2019 - Present",
      location: "Toronto, Canada",
      responsibilities: [
        "Built scalable NLP pipelines for chat summarization",
        "Deployed custom fine-tuned LLMs using HuggingFace Transformers",
        "Led model governance and explainability initiatives",
      ],
    ),
    ExperienceItem(
      company: "DataNest",
      position: "Machine Learning Engineer",
      duration: "2016 - 2019",
      location: "Toronto, Canada",
      responsibilities: [
        "Created recommendation systems and A/B tested ML features",
        "Integrated ML models into production REST APIs",
      ],
    ),
  ],
  education: [
    EducationItem(institution: "University of Toronto", degree: "MS in AI and Robotics", year: "2016"),
  ],
  skills: [
    SkillCategory(category: "ML/AI", items: ["PyTorch", "Transformers", "LangChain", "LLMs"]),
    SkillCategory(category: "MLOps", items: ["MLflow", "Kubeflow", "Vertex AI", "Docker"]),
  ],
  projects: [
    ProjectItem(
      name: "VoiceBot AI",
      description: "Multi-language voice assistant deployed to smart devices",
      technologies: ["Python", "ONNX", "Triton", "TTS/STT APIs"],
    ),
  ],
  certifications: [
    CertificationItem(name: "TensorFlow Developer Certificate", year: "2020"),
  ],
  languages: [
    LanguageItem(name: "English", proficiency: "Fluent"),
    LanguageItem(name: "Urdu", proficiency: "Native"),
  ],
);

final resume22 = Resume(
  heading: Heading(
    name: "Lina Schmidt",
    position: "Engineering Manager",
    avatar: null,
  ),
  summary: "Engineering manager with 10+ years of experience growing technical teams, driving agile delivery, and improving engineering culture.",
  contact: [
    ContactItem(type: "email", value: "lina.schmidt@teamsync.io"),
    ContactItem(type: "linkedin", value: "linkedin.com/in/linaschmidt"),
  ],
  experience: [
    ExperienceItem(
      company: "TeamSync",
      position: "Engineering Manager",
      duration: "2018 - Present",
      location: "Berlin, Germany",
      responsibilities: [
        "Scaled team from 5 to 30 engineers across 4 squads",
        "Introduced quarterly OKRs and performance reviews",
        "Collaborated with product/design to deliver roadmap efficiently",
      ],
    ),
    ExperienceItem(
      company: "CodeWorks GmbH",
      position: "Senior Frontend Engineer",
      duration: "2012 - 2018",
      location: "Berlin, Germany",
      responsibilities: [
        "Built responsive UI for B2B SaaS platform",
        "Mentored junior devs and conducted code reviews",
      ],
    ),
  ],
  education: [
    EducationItem(institution: "TU Berlin", degree: "MSc in Software Engineering", year: "2012"),
  ],
  skills: [
    SkillCategory(category: "Leadership", items: ["Agile", "OKRs", "Team Management"]),
    SkillCategory(category: "Tech", items: ["React", "Node.js", "PostgreSQL"]),
  ],
  projects: null,
  certifications: null,
  languages: [
    LanguageItem(name: "German", proficiency: "Native"),
    LanguageItem(name: "English", proficiency: "Fluent"),
  ],
);


class ResumeParserScreen extends StatefulWidget {
  const ResumeParserScreen({super.key});

  @override
  _ResumeParserScreenState createState() => _ResumeParserScreenState();
}

class _ResumeParserScreenState extends State<ResumeParserScreen> {
  File? _resumeFile;
  bool _isLoading = false;
  String _errorMessage = '';
  final TextEditingController _apiKeyController = TextEditingController();

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
        _errorMessage = '';
      });
    }
  }

  Future<String> _extractTextFromPdf() async {
    String text = "";
    try {
      if (_resumeFile == null) {
        throw Exception('No file selected');
      }
      text = await ReadPdfText.getPDFtext(_resumeFile!.path);
    } catch (e) {
      print('Failed to get PDF text error: $e');
    }
    return text;
  }

  Future<void> _parseAndGenerateResume() async {
    if (_resumeFile == null || _apiKeyController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a PDF file and enter your Gemini API key';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Extract text from PDF
      final resumeText = await _extractTextFromPdf();

      // Initialize the Gemini model
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKeyController.text,
      );

      // Create a prompt for Gemini
      const String prompt = '''
You are a resume parser. Extract only structured data from the resume text and return **only valid JSON** in the following format, without any additional explanation, titles, or text:

{
  "heading": {
    "name": "",
    "position": "",
    "avatar": ""
  },
  "summary": "",
  "contact": [
    {
      "type": "email",
      "value": ""
    }
  ],
  "experience": [
    {
      "company": "",
      "position": "",
      "duration": "",
      "location": "",
      "responsibilities": []
    }
  ],
  "education": [
    {
      "institution": "",
      "degree": "",
      "year": ""
    }
  ],
  "skills": [
    {
      "category": "",
      "items": []
    }
  ],
  "projects": [
    {
      "name": "",
      "description": "",
      "technologies": []
    }
  ],
  "certifications": [
    {
      "name": "",
      "year": ""
    }
  ],
  "languages": [
    {
      "name": "",
      "proficiency": ""
    }
  ]
}

Make sure your output is pure JSON and parsable. Do not include any pretext or explanation.
''';


      // Get the response from Gemini
      final content = Content.text(prompt);
      final response = await model.generateContent([content]);
      var responseText = response.text ?? '';

      // Clean up the response
      if (responseText.startsWith('json')) {
        responseText = responseText.substring(7);
      }
      if (responseText.endsWith('')) {
        responseText = responseText.substring(0, responseText.length - 3);
      }

      debugPrint('Gemini response: $responseText');

      // Parse the JSON response
      final jsonResponse = jsonDecode(responseText);
      final parsedResume = Resume.fromJson(jsonResponse);

      // Generate PDF directly
      await _generatePdf(parsedResume);

    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _errorMessage = 'PDF too large, please try a smaller file.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePdf(Resume resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildPdfHeader(resume.heading),
          pw.SizedBox(height: 20),
          _buildPdfSummary(resume.summary),
          pw.SizedBox(height: 20),
          _buildPdfContact(resume.contact),
          pw.SizedBox(height: 20),
          _buildPdfExperience(resume.experience),
          pw.SizedBox(height: 20),
          if (resume.education != null) _buildPdfEducation(resume.education!),
          pw.SizedBox(height: 20),
          if (resume.skills != null) _buildPdfSkills(resume.skills!),
          pw.SizedBox(height: 20),
          if (resume.projects != null) _buildPdfProjects(resume.projects!),
          pw.SizedBox(height: 20),
          if (resume.certifications != null) _buildPdfCertifications(resume.certifications!),
          pw.SizedBox(height: 20),
          if (resume.languages != null) _buildPdfLanguages(resume.languages!),
        ],
      ),
    );

    // Save and open the PDF
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/resume_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF resume generated successfully!')),
      );
    }
  }

  // PDF building methods
  pw.Widget _buildPdfHeader(Heading? heading) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              heading?.name ?? 'Your Name',
              style:  pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              heading?.position ?? 'Professional Title',
              style: const pw.TextStyle(
                fontSize: 16,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfSummary(String? summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Summary',
          style:  pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.Divider(),
        pw.Text(
          summary ?? 'Professional summary goes here',
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  pw.Widget _buildPdfContact(List<ContactItem>? contact) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Contact',
          style:  pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.Divider(),
        pw.Wrap(
          spacing: 20,
          runSpacing: 10,
          children: (contact ?? []).map((item) {
            return pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  '${item.type}: ',
                  style:  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(item.value ?? ''),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildPdfExperience(List<ExperienceItem>? experience) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Experience',
          style:  pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.Divider(),
        ...(experience ?? []).map((exp) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  exp.company ?? 'Company',
                  style:  pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  exp.duration ?? 'Duration',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            pw.Text(
              '${exp.position}${exp.location != null ? ' (${exp.location})' : ''}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),
            ...(exp.responsibilities ?? []).map((resp) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, bottom: 5),
              child: pw.Text(
                resp,
                style: const pw.TextStyle(fontSize: 12),
              ),
            )),
            pw.SizedBox(height: 15),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildPdfEducation(List<EducationItem> education) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Education',
          style:  pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.Divider(),
        ...education.map((edu) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  edu.institution ?? 'Institution',
                  style:  pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  edu.year ?? 'Year',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            pw.Text(
              edu.degree ?? 'Degree',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildPdfSkills(List<SkillCategory> skills) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Skills',
          style:  pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.Divider(),
        ...skills.map((category) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              category.category ?? 'Category',
              style:  pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: (category.items ?? []).map((skill) => pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(skill),
              )).toList(),
            ),
            pw.SizedBox(height: 10),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildPdfProjects(List<ProjectItem> projects) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Projects',
          style:  pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.Divider(),
        ...projects.map((project) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              project.name ?? 'Project Name',
              style:  pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              project.description ?? 'Project description',
              style: const pw.TextStyle(fontSize: 12),
            ),
            if (project.technologies != null && project.technologies!.isNotEmpty)
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: project.technologies!.map((tech) => pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Text(tech),
                )).toList(),
              ),
            pw.SizedBox(height: 15),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildPdfCertifications(List<CertificationItem> certifications) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Certifications',
          style:  pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.Divider(),
        ...certifications.map((cert) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  cert.name ?? 'Certification',
                  style:  pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  cert.year ?? 'Year',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildPdfLanguages(List<LanguageItem> languages) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Languages',
          style:  pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.Divider(),
        pw.Wrap(
          spacing: 20,
          runSpacing: 10,
          children: languages.map((lang) => pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                lang.name ?? 'Language',
                style: const pw.TextStyle(fontSize: 12),
              ),
              if (lang.proficiency != null) pw.Text(
                ' (${lang.proficiency})',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          )).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Parser with Gemini'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickResume,
              child: const Text('Select Resume PDF'),
            ),
            const SizedBox(height: 8),
            Text(
              _resumeFile?.path ?? 'No file selected',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _parseAndGenerateResume,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generate Resume PDF'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = "AIzaSyAamZnC3rXzQKNLwC_8ju0p-ScLylh9JEE";
  }
}