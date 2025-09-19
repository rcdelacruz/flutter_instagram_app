# Flutter Instagram Training - Quick Reference Guide

## Training Resources Overview

### Core Documentation
- **[Training Deliverables Guide](training-deliverables-guide.md)** - Detailed weekly tasks and requirements
- **[Repository Setup Guide](repository-setup-guide.md)** - Git workflow and repository management
- **[Self-Paced Training Guide](self-paced-training-guide.md)** - Learning path and resources
- **[Project Ideas](project-ideas.md)** - Additional practice projects

### Technical Documentation
- **[App Architecture](../architecture/app-architecture.md)** - System design and patterns
- **[Supabase Setup](../setup/supabase-setup.md)** - Backend configuration
- **[Testing Guide](../testing/testing-guide.md)** - Testing strategies and tools

## 10-Week Training Schedule

| Week | Focus Area | Key Deliverables | Estimated Hours |
|------|------------|------------------|-----------------|
| 1 | Foundation & Setup | Environment, Supabase, Project Structure | 15-20 |
| 2 | Authentication | Login, Signup, Social Auth, State Management | 20-25 |
| 3 | UI & Navigation | Components, Routing, Responsive Design | 20-25 |
| 4 | User Profiles | Profile Management, Image Upload, Settings | 20-25 |
| 5 | Post Creation | Camera, Gallery, Filters, Media Upload | 25-30 |
| 6 | Feed System | Post Display, Infinite Scroll, Caching | 25-30 |
| 7 | Social Features | Likes, Comments, Following, Discovery | 25-30 |
| 8 | Real-time & Notifications | Live Updates, Push Notifications | 25-30 |
| 9 | Advanced Features | Search, Stories, Messaging, Explore | 30-35 |
| 10 | Testing & Deployment | Testing, Optimization, App Store Prep | 25-30 |

**Total Estimated Time**: 230-280 hours (23-28 hours per week)

## Weekly Milestones & Success Criteria

### Week 1: Foundation
**Success Criteria:**
- [ ] Flutter app runs without errors
- [ ] Supabase connection established
- [ ] Project structure documented
- [ ] Development environment fully configured

**Key Files to Review:**
- `lib/main.dart` - App initialization
- `lib/config/app_config.dart` - Configuration
- `.env` - Environment variables
- `pubspec.yaml` - Dependencies

### Week 2: Authentication
**Success Criteria:**
- [ ] Complete auth flow (signup, login, logout)
- [ ] Social authentication working
- [ ] Session persistence implemented
- [ ] Auth state management with Riverpod

**Key Files to Review:**
- `lib/providers/auth_provider.dart`
- `lib/services/auth_service.dart`
- `lib/screens/auth/` directory
- Auth-related tests

### Week 3: UI & Navigation
**Success Criteria:**
- [ ] Bottom tab navigation working
- [ ] Reusable component library created
- [ ] Responsive layouts implemented
- [ ] Smooth animations and transitions

**Key Files to Review:**
- `lib/widgets/` directory
- Navigation configuration
- Theme and styling files
- Component documentation

### Week 4: User Profiles
**Success Criteria:**
- [ ] Profile display and editing working
- [ ] Image upload to Supabase storage
- [ ] Profile settings functional
- [ ] State management for profiles

**Key Files to Review:**
- `lib/models/user.dart`
- Profile-related screens
- Image upload implementation
- Profile state providers

### Week 5: Post Creation
**Success Criteria:**
- [ ] Camera and gallery integration
- [ ] Media upload with progress tracking
- [ ] Basic image editing/filters
- [ ] Post publishing system

**Key Files to Review:**
- `lib/models/post.dart`
- Camera and image picker implementation
- Media upload service
- Post creation UI

### Week 6: Feed System
**Success Criteria:**
- [ ] Infinite scrolling feed
- [ ] Efficient image caching
- [ ] Stories section functional
- [ ] Smooth performance with large datasets

**Key Files to Review:**
- Feed data providers
- `lib/widgets/post_card.dart`
- Caching implementation
- Performance optimizations

### Week 7: Social Features
**Success Criteria:**
- [ ] Like and comment systems working
- [ ] Following/followers functionality
- [ ] User discovery and search
- [ ] Activity feed implemented

**Key Files to Review:**
- Social interaction models
- Like/comment implementations
- Search functionality
- Activity feed logic

### Week 8: Real-time & Notifications
**Success Criteria:**
- [ ] Real-time updates working
- [ ] Push notifications configured
- [ ] Background sync implemented
- [ ] Online presence indicators

**Key Files to Review:**
- Real-time subscription setup
- Notification service
- Background sync logic
- Presence tracking

### Week 9: Advanced Features
**Success Criteria:**
- [ ] Advanced search implemented
- [ ] Stories feature complete
- [ ] Direct messaging working
- [ ] Explore page functional

**Key Files to Review:**
- Search implementation
- Stories functionality
- Messaging system
- Recommendation algorithms

### Week 10: Testing & Deployment
**Success Criteria:**
- [ ] Comprehensive test suite (>70% coverage)
- [ ] Performance optimized
- [ ] App store ready builds
- [ ] Complete documentation

**Key Files to Review:**
- Test files and coverage reports
- Performance benchmarks
- Build configurations
- Documentation completeness

## Development Tools & Commands

### Essential Flutter Commands
```bash
# Development
flutter run                    # Run app in debug mode
flutter run --release         # Run in release mode
flutter hot-reload            # Hot reload (r in terminal)
flutter hot-restart           # Hot restart (R in terminal)

# Testing
flutter test                  # Run unit and widget tests
flutter test --coverage      # Run tests with coverage
flutter test integration_test/ # Run integration tests

# Code Quality
flutter analyze              # Static analysis
flutter format .             # Format code
dart fix --apply             # Apply suggested fixes

# Build
flutter build apk            # Build Android APK
flutter build ios            # Build iOS app
flutter build web            # Build web app

# Dependencies
flutter pub get              # Install dependencies
flutter pub upgrade          # Upgrade dependencies
flutter pub deps             # Show dependency tree
```

### Git Workflow Commands
```bash
# Daily workflow
git status                   # Check current status
git add .                    # Stage all changes
git commit -m "message"      # Commit with message
git push training branch     # Push to training repo

# Weekly workflow
git checkout -b week-X-feature  # Create week branch
git merge week-X-feature        # Merge completed work
git tag week-X-complete         # Tag completion
git push training --tags        # Push tags

# Maintenance
git fetch upstream           # Get upstream changes
git merge upstream/main      # Merge upstream
git remote -v               # Check remotes
```

### Supabase Commands
```bash
# Local development
supabase start              # Start local Supabase
supabase stop               # Stop local Supabase
supabase status             # Check status
supabase db reset           # Reset database

# Database
supabase db diff            # Show schema changes
supabase db push            # Push schema changes
supabase db pull            # Pull schema changes

# Functions
supabase functions serve    # Serve functions locally
supabase functions deploy   # Deploy functions
```

## Review Checklists

### Code Review Checklist
- [ ] **Functionality**: Features work as expected
- [ ] **Code Quality**: Clean, readable, well-structured
- [ ] **Performance**: No memory leaks or performance issues
- [ ] **Testing**: Adequate test coverage
- [ ] **Documentation**: Code is properly documented
- [ ] **Error Handling**: Proper error handling implemented
- [ ] **Security**: No security vulnerabilities
- [ ] **Accessibility**: Basic accessibility features
- [ ] **Responsive**: Works on different screen sizes
- [ ] **Best Practices**: Follows Flutter/Dart conventions

### Weekly Submission Checklist
- [ ] **All tasks completed** or clearly marked as in-progress
- [ ] **Code pushed** to training repository
- [ ] **Tests passing** with adequate coverage
- [ ] **Documentation updated** including training log
- [ ] **Demo video/screenshots** provided
- [ ] **Weekly report** completed
- [ ] **Issues/challenges** documented
- [ ] **Next week preparation** outlined

### Deployment Readiness Checklist
- [ ] **All features working** on target platforms
- [ ] **Performance optimized** and tested
- [ ] **Security reviewed** and hardened
- [ ] **Tests comprehensive** with high coverage
- [ ] **Documentation complete** and up-to-date
- [ ] **App store assets** prepared
- [ ] **Build configuration** properly set up
- [ ] **Privacy policy** and terms created
- [ ] **Analytics** and crash reporting configured
- [ ] **Backup and recovery** procedures documented

## Common Issues & Solutions

### Development Issues

**Issue**: Flutter doctor shows issues
```bash
# Solution: Follow specific doctor recommendations
flutter doctor --verbose
# Install missing components as indicated
```

**Issue**: Pub get fails
```bash
# Solution: Clear cache and retry
flutter clean
flutter pub cache repair
flutter pub get
```

**Issue**: Hot reload not working
```bash
# Solution: Hot restart or full restart
# Press 'R' in terminal or restart debug session
```

**Issue**: Supabase connection fails
```bash
# Solution: Check environment variables
# Verify .env file exists and has correct values
# Check Supabase project status
```

### Git Issues

**Issue**: Merge conflicts
```bash
# Solution: Resolve conflicts manually
git status                    # See conflicted files
# Edit files to resolve conflicts
git add .
git commit -m "Resolve conflicts"
```

**Issue**: Can't push to repository
```bash
# Solution: Check remote and permissions
git remote -v                 # Verify remote URLs
git push -u training branch   # Set upstream
```

**Issue**: Lost commits
```bash
# Solution: Use reflog to recover
git reflog                    # Find lost commits
git checkout commit-hash      # Recover specific commit
```

### Performance Issues

**Issue**: App startup slow
- Check for unnecessary imports
- Optimize initialization code
- Use lazy loading where possible

**Issue**: Scrolling performance poor
- Implement proper list builders
- Use image caching
- Optimize widget rebuilds

**Issue**: Memory usage high
- Check for memory leaks
- Dispose controllers properly
- Optimize image loading

## Getting Help

### Escalation Path
1. **Self-Help**: Check documentation and common issues
2. **Peer Help**: Ask in training community chat
3. **Mentor Help**: Create help-wanted issue
4. **Expert Help**: Schedule 1:1 session for complex issues

### Support Channels
- **Training Discord**: Real-time chat and help
- **GitHub Issues**: Structured help requests
- **Weekly Check-ins**: Regular progress reviews
- **Office Hours**: Scheduled mentor availability

### Resources
- **Flutter Documentation**: https://docs.flutter.dev/
- **Supabase Documentation**: https://supabase.com/docs
- **Riverpod Documentation**: https://riverpod.dev/
- **Material Design**: https://material.io/design

Remember: Learning is a journey, not a destination. Focus on understanding concepts, not just completing tasks!
