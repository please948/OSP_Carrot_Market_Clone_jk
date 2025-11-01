# 개발 가이드

이 문서는 프로젝트에 기능을 추가하거나 수정할 때 따라야 할 절차를 설명합니다.

## 📋 개발 전 준비사항

### 1. 최신 코드 가져오기

작업을 시작하기 전에 항상 원격 저장소의 최신 변경사항을 가져옵니다:

```bash
git fetch origin
git pull origin main
```

### 2. 브랜치 전략

새로운 기능을 개발할 때는 `main` 브랜치에서 직접 작업하지 않고, 새로운 브랜치를 만들어서 작업합니다.

```bash
# main 브랜치로 이동
git checkout main

# 최신 코드로 업데이트
git pull origin main

# 새 기능 브랜치 생성 및 이동
git checkout -b feature/기능명

# 예시:
# git checkout -b feature/product-search
# git checkout -b feature/user-profile
# git checkout -b feature/payment-integration
```

## 🔨 개발 절차

### 1. 기능 개발

브랜치를 만든 후 코드를 작성하고 수정합니다.

### 2. 변경사항 확인

작업한 내용을 확인합니다:

```bash
# 변경된 파일 확인
git status

# 변경 내용 확인
git diff
```

### 3. 변경사항 스테이징 (Staging)

변경사항을 커밋하기 전에 스테이징 영역에 추가합니다:

```bash
# 특정 파일만 추가
git add lib/pages/new_page.dart

# 모든 변경사항 추가
git add .

# 특정 디렉토리 추가
git add lib/pages/
```

### 4. 커밋 (Commit)

의미 있는 단위로 커밋합니다:

```bash
git commit -m "커밋 메시지"

# 좋은 커밋 메시지 예시:
# git commit -m "feat: 상품 검색 기능 추가"
# git commit -m "fix: 로그인 버그 수정"
# git commit -m "docs: README 업데이트"
# git commit -m "style: 코드 포맷팅"
```

**커밋 메시지 컨벤션:**
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 수정
- `style`: 코드 포맷팅, 세미콜론 누락 등
- `refactor`: 코드 리팩토링
- `test`: 테스트 코드 추가
- `chore`: 빌드 업무 수정, 패키지 매니저 설정 등

### 5. 원격 저장소에 푸시

작업한 브랜치를 원격 저장소에 푸시합니다:

```bash
# 첫 푸시 시 (브랜치가 원격에 없을 때)
git push -u origin feature/기능명

# 이후 푸시 (브랜치가 이미 원격에 있을 때)
git push
```

### 6. Pull Request (PR) 생성

GitHub 웹사이트에서 Pull Request를 생성합니다:

1. GitHub 저장소 페이지 접속
2. "Compare & pull request" 버튼 클릭 (푸시 후 자동으로 나타남)
3. PR 제목과 설명 작성
4. 리뷰어 지정 (협업하는 경우)
5. "Create pull request" 클릭

### 7. 코드 리뷰 및 수정

PR이 생성되면:
- 다른 개발자가 코드를 리뷰할 수 있습니다
- 피드백을 받으면 수정 후 다시 커밋/푸시합니다
- 자동으로 PR이 업데이트됩니다

### 8. Merge (병합)

리뷰가 완료되고 승인되면 `main` 브랜치에 병합합니다:

```bash
# GitHub에서 "Merge pull request" 버튼으로 병합하거나
# 또는 로컬에서:
git checkout main
git pull origin main
git merge feature/기능명
git push origin main
```

### 9. 브랜치 정리

병합이 완료된 후 로컬 브랜치를 삭제합니다:

```bash
# main 브랜치로 이동
git checkout main

# 로컬 브랜치 삭제
git branch -d feature/기능명

# 원격 브랜치 삭제 (선택사항)
git push origin --delete feature/기능명
```

## 🔄 일상적인 개발 워크플로우

```bash
# 1. 최신 코드 가져오기
git checkout main
git pull origin main

# 2. 새 브랜치 생성
git checkout -b feature/new-feature

# 3. 코드 수정 및 개발
# ... (코드 작성) ...

# 4. 변경사항 확인
git status
git diff

# 5. 스테이징 및 커밋
git add .
git commit -m "feat: 새 기능 추가"

# 6. 푸시
git push -u origin feature/new-feature

# 7. GitHub에서 PR 생성 및 리뷰

# 8. 병합 후 정리
git checkout main
git pull origin main
git branch -d feature/new-feature
```

## ⚠️ 주의사항

### 절대 하지 말아야 할 것

1. **main 브랜치에서 직접 작업하지 않기**
   - 항상 기능 브랜치를 만들어서 작업하세요

2. **커밋하지 말아야 할 파일 커밋하기**
   - `.gitignore`에 포함된 파일은 절대 커밋하지 마세요
   - 특히 `api_keys.dart`, `google-services.json` 등

3. **의미 없는 커밋 메시지**
   - "수정", "asdf", "test" 같은 메시지는 피하세요
   - 무엇을, 왜 수정했는지 명확하게 작성하세요

4. **너무 큰 커밋**
   - 한 번에 여러 기능을 섞어서 커밋하지 마세요
   - 논리적인 단위로 나눠서 커밋하세요

### 되돌리기 (Undo)

```bash
# 스테이징 취소 (add 취소)
git reset HEAD 파일명

# 마지막 커밋 취소 (변경사항은 유지)
git reset --soft HEAD~1

# 마지막 커밋 완전히 취소 (변경사항도 삭제)
git reset --hard HEAD~1

# 파일 변경사항 취소 (아직 커밋하지 않은 경우)
git checkout -- 파일명
```

## 🔧 유용한 Git 명령어

```bash
# 브랜치 목록 확인
git branch

# 원격 브랜치 포함 목록 확인
git branch -a

# 현재 상태 확인
git status

# 커밋 히스토리 확인
git log --oneline

# 원격 저장소 정보 확인
git remote -v

# 특정 파일의 변경 이력 확인
git log 파일명

# 변경사항 미리보기 (커밋 전)
git diff --staged
```

## 📚 참고 자료

- [Git 공식 문서](https://git-scm.com/doc)
- [GitHub 가이드](https://guides.github.com/)
- [커밋 메시지 컨벤션](https://www.conventionalcommits.org/)

