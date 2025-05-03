class Resume {
  final Heading? heading;
  final String? summary;
  final List<ContactItem>? contact;
  final List<ExperienceItem>? experience;
  final List<EducationItem>? education;
  final List<SkillCategory>? skills;
  final List<ProjectItem>? projects;
  final List<CertificationItem>? certifications;
  final List<LanguageItem>? languages;

  Resume({
    this.heading,
    this.summary,
    this.contact,
    this.experience,
    this.education,
    this.skills,
    this.projects,
    this.certifications,
    this.languages,
  });

  Map<String, dynamic> toJson() {
    return {
      'heading': heading?.toJson(),
      'summary': summary,
      'contact': contact?.map((e) => e.toJson()).toList(),
      'experience': experience?.map((e) => e.toJson()).toList(),
      'education': education?.map((e) => e.toJson()).toList(),
      'skills': skills?.map((e) => e.toJson()).toList(),
      'projects': projects?.map((e) => e.toJson()).toList(),
      'certifications': certifications?.map((e) => e.toJson()).toList(),
      'languages': languages?.map((e) => e.toJson()).toList(),
    };
  }

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      heading: json['heading'] != null ? Heading.fromJson(json['heading']) : null,
      summary: json['summary'],
      contact: json['contact'] != null
          ? (json['contact'] as List).map((e) => ContactItem.fromJson(e)).toList()
          : null,
      experience: json['experience'] != null
          ? (json['experience'] as List).map((e) => ExperienceItem.fromJson(e)).toList()
          : null,
      education: json['education'] != null
          ? (json['education'] as List).map((e) => EducationItem.fromJson(e)).toList()
          : null,
      skills: json['skills'] != null
          ? (json['skills'] as List).map((e) => SkillCategory.fromJson(e)).toList()
          : null,
      projects: json['projects'] != null
          ? (json['projects'] as List).map((e) => ProjectItem.fromJson(e)).toList()
          : null,
      certifications: json['certifications'] != null
          ? (json['certifications'] as List).map((e) => CertificationItem.fromJson(e)).toList()
          : null,
      languages: json['languages'] != null
          ? (json['languages'] as List).map((e) => LanguageItem.fromJson(e)).toList()
          : null,
    );
  }
}

class Heading {
  final String? name;
  final String? position;
  final String? avatar;

  Heading({
    this.name,
    this.position,
    this.avatar,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'avatar': avatar,
    };
  }

  factory Heading.fromJson(Map<String, dynamic> json) {
    return Heading(
      name: json['name'],
      position: json['position'],
      avatar: json['avatar'],
    );
  }
}

class ContactItem {
  final String? type;
  final String? value;

  ContactItem({
    this.type,
    this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
    };
  }

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      type: json['type'],
      value: json['value'],
    );
  }
}

class ExperienceItem {
  final String? company;
  final String? position;
  final String? duration;
  final String? location;
  final List<String>? responsibilities;

  ExperienceItem({
    this.company,
    this.position,
    this.duration,
    this.location,
    this.responsibilities,
  });

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'position': position,
      'duration': duration,
      'location': location,
      'responsibilities': responsibilities,
    };
  }

  factory ExperienceItem.fromJson(Map<String, dynamic> json) {
    return ExperienceItem(
      company: json['company'],
      position: json['position'],
      duration: json['duration'],
      location: json['location'],
      responsibilities: json['responsibilities'] != null
          ? List<String>.from(json['responsibilities'])
          : null,
    );
  }
}

class EducationItem {
  final String? institution;
  final String? degree;
  final String? year;

  EducationItem({
    this.institution,
    this.degree,
    this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'degree': degree,
      'year': year,
    };
  }

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      institution: json['institution'],
      degree: json['degree'],
      year: json['year'],
    );
  }
}

class SkillCategory {
  final String? category;
  final List<String>? items;

  SkillCategory({
    this.category,
    this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'items': items,
    };
  }

  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    return SkillCategory(
      category: json['category'],
      items: json['items'] != null ? List<String>.from(json['items']) : null,
    );
  }
}

class ProjectItem {
  final String? name;
  final String? description;
  final List<String>? technologies;

  ProjectItem({
    this.name,
    this.description,
    this.technologies,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'technologies': technologies,
    };
  }

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    return ProjectItem(
      name: json['name'],
      description: json['description'],
      technologies: json['technologies'] != null
          ? List<String>.from(json['technologies'])
          : null,
    );
  }
}

class CertificationItem {
  final String? name;
  final String? year;

  CertificationItem({
    this.name,
    this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'year': year,
    };
  }

  factory CertificationItem.fromJson(Map<String, dynamic> json) {
    return CertificationItem(
      name: json['name'],
      year: json['year'],
    );
  }
}

class LanguageItem {
  final String? name;
  final String? proficiency;

  LanguageItem({
    this.name,
    this.proficiency,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'proficiency': proficiency,
    };
  }

  factory LanguageItem.fromJson(Map<String, dynamic> json) {
    return LanguageItem(
      name: json['name'],
      proficiency: json['proficiency'],
    );
  }
}