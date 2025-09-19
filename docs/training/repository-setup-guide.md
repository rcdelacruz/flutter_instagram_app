# Repository Setup Guide for Flutter Instagram Training

## Overview

This guide provides step-by-step instructions for setting up your personal training repository, forking the main project, and establishing a proper development workflow for the 10-week Flutter Instagram app training program.

## Prerequisites

Before starting, ensure you have:
- Git installed on your computer
- GitHub account created
- Flutter SDK installed
- IDE setup (VS Code or Android Studio)
- Basic understanding of Git commands

## Step 1: Fork the Main Repository

### 1.1 Fork on GitHub

1. Navigate to the main repository: `https://github.com/[organization]/flutter_instagram_app`
2. Click the **"Fork"** button in the top-right corner
3. Select your GitHub account as the destination
4. Wait for the fork to complete

### 1.2 Clone Your Fork

```bash
# Clone your forked repository
git clone https://github.com/[your-username]/flutter_instagram_app.git

# Navigate to the project directory
cd flutter_instagram_app

# Verify the remote origin
git remote -v
```

### 1.3 Add Upstream Remote

```bash
# Add the original repository as upstream
git remote add upstream https://github.com/[organization]/flutter_instagram_app.git

# Verify all remotes
git remote -v
# Should show:
# origin    https://github.com/[your-username]/flutter_instagram_app.git (fetch)
# origin    https://github.com/[your-username]/flutter_instagram_app.git (push)
# upstream  https://github.com/[organization]/flutter_instagram_app.git (fetch)
# upstream  https://github.com/[organization]/flutter_instagram_app.git (push)
```

## Step 2: Create Your Training Repository

### 2.1 Create New Repository on GitHub

1. Go to GitHub and click **"New repository"**
2. Repository name: `flutter-instagram-training-[your-name]`
3. Description: "My Flutter Instagram app training progress"
4. Set to **Public** (for easy sharing with mentors)
5. Initialize with README
6. Add .gitignore: **Flutter**
7. Choose a license (MIT recommended)
8. Click **"Create repository"**

### 2.2 Set Up Training Branch

```bash
# Create and switch to your training branch
git checkout -b training/[your-name]

# Example: git checkout -b training/john-doe

# Add your training repository as a remote
git remote add training https://github.com/[your-username]/flutter-instagram-training-[your-name].git

# Push your training branch to the training repository
git push training training/[your-name]

# Set up tracking for your training branch
git branch --set-upstream-to=training/training/[your-name] training/[your-name]
```

## Step 3: Initial Project Setup

### 3.1 Verify Flutter Setup

```bash
# Check Flutter installation
flutter doctor

# Install dependencies
flutter pub get

# Run the app to verify everything works
flutter run
```

### 3.2 Create Initial Documentation

Create a `TRAINING_LOG.md` file in your repository root:

```markdown
# Flutter Instagram Training Log

## Trainee Information
- **Name**: [Your Name]
- **GitHub**: [@your-username](https://github.com/your-username)
- **Training Repository**: [Link to your training repo]
- **Start Date**: [Date]
- **Expected Completion**: [Date + 10 weeks]

## Training Progress

### Week 1: Project Foundation & Environment Setup
- [ ] Environment Setup & Dependencies
- [ ] Project Structure Analysis
- [ ] Supabase Configuration
- [ ] App Theme & Constants Setup
- [ ] Basic App Structure

**Status**: Not Started
**Notes**:

---

### Week 2: Authentication System Implementation
- [ ] User Registration System
- [ ] Login System
- [ ] Password Reset Flow
- [ ] Social Authentication
- [ ] Authentication State Management
- [ ] Auth UI Components

**Status**: Not Started
**Notes**:

---

[Continue for all 10 weeks...]

## Weekly Reports

### Week 1 Report
**Date**:
**Completed Tasks**:
**Challenges**:
**Learnings**:
**Next Week Goals**:

---

## Resources and References
- [Main Repository](https://github.com/[organization]/flutter_instagram_app)
- [Training Documentation](link-to-docs)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
```

### 3.3 Commit Initial Setup

```bash
# Add all files
git add .

# Commit initial setup
git commit -m "Initial training setup and documentation"

# Push to your training repository
git push training training/[your-name]

# Tag the initial setup
git tag training-start
git push training training-start
```

## Step 4: Weekly Workflow

### 4.1 Starting a New Week

```bash
# Ensure you're on your training branch
git checkout training/[your-name]

# Pull latest changes from upstream (if any)
git fetch upstream
git merge upstream/main

# Create a branch for the week's work
git checkout -b week-[number]-[feature-name]
# Example: git checkout -b week-1-environment-setup
```

### 4.2 Daily Development Workflow

```bash
# Make your changes and commit frequently
git add .
git commit -m "Implement user registration form validation"

# Push to your training repository regularly
git push training week-[number]-[feature-name]
```

### 4.3 Completing a Week

```bash
# Switch back to your main training branch
git checkout training/[your-name]

# Merge your week's work
git merge week-[number]-[feature-name]

# Update your training log
# Edit TRAINING_LOG.md with week's progress

# Commit the week's completion
git add .
git commit -m "Week [number] complete: [brief description]"

# Tag the week's completion
git tag week-[number]-complete
git push training training/[your-name] --tags

# Create a pull request for review (optional)
# Go to GitHub and create PR from week branch to training branch
```

## Step 5: Sharing and Collaboration

### 5.1 Weekly Submissions

Create weekly submission issues in your training repository:

1. Go to your training repository on GitHub
2. Click **"Issues"** tab
3. Click **"New issue"**
4. Title: "Week [X] Submission - [Feature Name]"
5. Use this template:

```markdown
## Week [X] Submission: [Feature Name]

### Completed Tasks
- [x] Task 1: Description
- [x] Task 2: Description
- [ ] Task 3: In progress

### Demo Links
- **Live Demo**: [Link if deployed]
- **Video Walkthrough**: [Link to video]
- **Screenshots**: [Attach screenshots]

### Code Changes
- **Branch**: week-[X]-[feature-name]
- **Commits**: [Number] commits
- **Files Changed**: [Number] files

### Challenges Faced
1. Challenge description and resolution
2. Another challenge and current status

### Key Learnings
1. Technical learning
2. Best practice discovered

### Questions for Review
1. Question about implementation
2. Request for feedback on approach

### Next Week Preparation
- [ ] Preparation task 1
- [ ] Preparation task 2

### Self-Assessment
- **Code Quality**: [1-10]
- **Feature Completeness**: [1-10]
- **Documentation**: [1-10]
- **Testing**: [1-10]

### Mentor Review Requested
- [ ] Code review
- [ ] Architecture feedback
- [ ] Performance review
- [ ] Best practices guidance

@mentor-username Please review when convenient.
```

### 5.2 Getting Help

#### Create Help Issues
When stuck, create an issue with the "help-wanted" label:

```markdown
## Help Needed: [Brief Description]

### Problem Description
Clear description of what you're trying to achieve and what's not working.

### What I've Tried
1. Approach 1 and result
2. Approach 2 and result

### Code Snippets
```dart
// Relevant code that's causing issues
```

### Error Messages
```
Error message or unexpected behavior
```

### Environment
- Flutter version:
- Platform: iOS/Android/Web
- Device/Emulator:

### Expected Behavior
What should happen

### Actual Behavior
What actually happens

### Additional Context
Any other relevant information
```

#### Join Training Community
- Join the training Discord/Slack channel
- Participate in weekly check-ins
- Share progress and help others
- Attend code review sessions

## Step 6: Keeping Your Fork Updated

### 6.1 Regular Updates

```bash
# Fetch latest changes from upstream
git fetch upstream

# Switch to your main training branch
git checkout training/[your-name]

# Merge upstream changes
git merge upstream/main

# Push updates to your training repository
git push training training/[your-name]
```

### 6.2 Handling Conflicts

If you encounter merge conflicts:

```bash
# View conflicted files
git status

# Edit files to resolve conflicts
# Look for <<<<<<< HEAD markers

# After resolving conflicts
git add .
git commit -m "Resolve merge conflicts with upstream"
git push training training/[your-name]
```

## Best Practices

### Commit Messages
Use clear, descriptive commit messages:
- ✅ "Implement user registration with email validation"
- ✅ "Add error handling for Supabase authentication"
- ✅ "Fix profile image upload progress indicator"
- ❌ "Fix bug"
- ❌ "Update code"
- ❌ "WIP"

### Branch Naming
Use consistent branch naming:
- `week-1-environment-setup`
- `week-2-authentication`
- `feature/user-profile-editing`
- `bugfix/image-upload-error`

### Documentation
- Update TRAINING_LOG.md weekly
- Document challenges and solutions
- Include screenshots and videos
- Write clear README files for major features

### Code Quality
- Follow Flutter/Dart style guidelines
- Write meaningful comments
- Include unit tests for business logic
- Use proper error handling
- Optimize for performance

## Troubleshooting

### Common Issues

**Issue**: Can't push to training repository
```bash
# Check remote URLs
git remote -v

# Re-add training remote if needed
git remote add training https://github.com/[your-username]/flutter-instagram-training-[your-name].git
```

**Issue**: Merge conflicts with upstream
```bash
# Create a backup branch first
git checkout -b backup-before-merge

# Then attempt merge on main training branch
git checkout training/[your-name]
git merge upstream/main
```

**Issue**: Lost work or corrupted repository
```bash
# Check reflog for recent commits
git reflog

# Recover specific commit
git checkout [commit-hash]
git checkout -b recovery-branch
```

### Getting Support

1. **Check Documentation**: Review training guides and Flutter docs
2. **Search Issues**: Look for similar problems in repository issues
3. **Ask Community**: Post in training Discord/Slack
4. **Create Issue**: Use the help-wanted template
5. **Schedule 1:1**: Book time with mentor for complex issues

Remember: The training is about learning, not just completing tasks. Document your journey, ask questions, and help others when you can!
