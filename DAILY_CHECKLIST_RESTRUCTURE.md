# Daily Checklist Restructuring - Complete Implementation

## Overview
Restructured the Daily Checklist feature to match the Inspection flow with proper data models, dynamic form rendering based on API response, and structured submission format.

---

## API Integration

### GET `/daily-checklist` - Fetch Checklist

**Response:**
```json
{
    "data": {
        "template": {
            "id": 6,
            "name": "dsff",
            "description": "sdfsdf"
        },
        "questions": [
            {
                "checklist_section_id": 13,
                "title": "dasda",
                "items": "[{\"id\": 24, \"question\": \"asdasd\", \"field_type\": \"boolean\", \"is_required\": 1}]"
            }
        ]
    },
    "message": "",
    "status": true
}
```

### POST `/daily-checklist-submit` - Submit Checklist

**Request Body:**
```json
{
  "user_id": 4,
  "vehicle_id": 2,
  "checklist_template_id": 6,
  "clockin_id": 6,
  "responses": [
    {
      "checklist_question_id": 28,
      "answer": "Yes",
      "remarks": null
    },
    {
      "checklist_question_id": 27,
      "answer": "Yes",
      "remarks": null
    },
    {
      "checklist_question_id": 26,
      "answer": "No",
      "remarks": null
    }
  ]
}
```

---

## New Data Models

### File: `checklist_model.dart`

#### 1. ChecklistItem
```dart
class ChecklistItem {
  final int id;
  final String question;
  final String fieldType;      // 'boolean', 'text', etc.
  final int isRequired;
  String? answer;               // User's answer
  String? remarks;              // Optional remarks

  // Computed properties
  bool get isBoolean => fieldType.toLowerCase() == 'boolean';
  bool get isText => fieldType.toLowerCase() == 'text';
  bool get isMandatory => isRequired == 1;
  bool get isAnswered => answer != null && answer!.isNotEmpty;
}
```

#### 2. ChecklistSection
```dart
class ChecklistSection {
  final int checklistSectionId;
  final String title;
  final List<ChecklistItem> items;

  // Progress tracking
  int get totalItems => items.length;
  int get answeredItems => items.where((item) => item.isAnswered).length;
  double get progress => totalItems > 0 ? answeredItems / totalItems : 0.0;
  bool get isComplete => answeredItems == totalItems;
}
```

#### 3. ChecklistTemplate
```dart
class ChecklistTemplate {
  final int id;
  final String name;
  final String description;
}
```

#### 4. DailyChecklistResponse
```dart
class DailyChecklistResponse {
  final ChecklistTemplate template;
  final List<ChecklistSection> questions;

  // Overall progress
  int get totalQuestions;
  int get answeredQuestions;
  double get overallProgress;
  bool get isComplete;
}
```

#### 5. ChecklistResponse (for submission)
```dart
class ChecklistResponse {
  final int checklistQuestionId;
  final String answer;
  final String? remarks;
}
```

---

## Updated Service Layer

### File: `checklist_service.dart`

#### Get Daily Checklist
```dart
Future<DailyChecklistResponse> getDailyChecklist() async {
  final response = await _apiClient.post<DailyChecklistResponse>(
    ApiConstants.dailyChecklist,
    fromJson: (data) => DailyChecklistResponse.fromJson(data),
  );

  if (response.isSuccess && response.data != null) {
    return response.data!;
  } else {
    throw ApiException(message: 'Failed to fetch daily checklist');
  }
}
```

#### Submit Daily Checklist
```dart
Future<void> submitDailyChecklist({
  required int vehicleId,
  required int checklistTemplateId,
  required List<ChecklistSection> sections,
  int? clockinId,
}) async {
  final userId = await StorageService.getUserId();
  
  // Build responses array from sections
  final List<Map<String, dynamic>> responses = [];

  for (var section in sections) {
    for (var item in section.items) {
      if (item.answer != null && item.answer!.isNotEmpty) {
        responses.add({
          'checklist_question_id': item.id,
          'answer': item.answer!,
          'remarks': item.remarks,
        });
      }
    }
  }

  // Prepare submission data
  final data = {
    'user_id': userId,
    'vehicle_id': vehicleId,
    'checklist_template_id': checklistTemplateId,
    if (clockinId != null) 'clockin_id': clockinId,
    'responses': responses,
  };

  final response = await _apiClient.post(
    ApiConstants.dailyChecklistSubmit,
    data: data,
  );
}
```

---

## Updated Controller Layer

### File: `daily_checklist_controller.dart`

#### State Management
```dart
class DailyChecklistController extends GetxController {
  // UI State
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final checklistResponse = Rxn<DailyChecklistResponse>();
  final errorMessage = RxnString();
  final sections = <ChecklistSection>[].obs;

  // Selected vehicle
  final selectedVehicleId = RxnInt();
}
```

#### Load Checklist
```dart
Future<void> loadChecklist() async {
  try {
    isLoading.value = true;
    errorMessage.value = null;

    final data = await _checklistService.getDailyChecklist();
    checklistResponse.value = data;
    sections.value = data.questions;  // Copy sections for user input
  } catch (e) {
    errorMessage.value = e.toString();
  } finally {
    isLoading.value = false;
  }
}
```

#### Update Answer
```dart
void updateAnswer(int sectionIndex, int itemIndex, String answer, {String? remarks}) {
  sections[sectionIndex].items[itemIndex].answer = answer;
  if (remarks != null) {
    sections[sectionIndex].items[itemIndex].remarks = remarks;
  }
  sections.refresh();  // Trigger UI update
}
```

#### Validation
```dart
bool get canSubmit {
  if (selectedVehicleId.value == null) return false;
  if (checklistResponse.value == null) return false;
  
  // Check if all mandatory questions are answered
  for (var section in sections) {
    for (var item in section.items) {
      if (item.isMandatory && !item.isAnswered) {
        return false;
      }
    }
  }
  return true;
}
```

#### Submit
```dart
Future<void> submitChecklist() async {
  if (selectedVehicleId.value == null) {
    Get.snackbar('Validation Error', 'Please select a vehicle');
    return;
  }

  if (!canSubmit) {
    Get.snackbar('Validation Error', 'Please answer all mandatory questions');
    return;
  }

  try {
    isSubmitting.value = true;

    // Get clockin_id from dashboard
    final dashboardController = Get.find<DriverDashboardController>();
    final clockinId = dashboardController.clockinId;

    await _checklistService.submitDailyChecklist(
      vehicleId: selectedVehicleId.value!,
      checklistTemplateId: checklistResponse.value!.template.id,
      sections: sections,
      clockinId: clockinId,
    );

    Get.snackbar(
      'Success',
      'Daily checklist submitted successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Refresh dashboard and go back
    final dashboardController = Get.find<DriverDashboardController>();
    await dashboardController.refreshDashboard();
    Get.back();
  } catch (e) {
    Get.snackbar('Error', 'Failed to submit checklist');
  } finally {
    isSubmitting.value = false;
  }
}
```

---

## Data Flow

### 1. Loading Flow
```
User opens Daily Checklist screen
    ↓
Controller.loadChecklist()
    ↓
ChecklistService.getDailyChecklist()
    ↓
API GET /daily-checklist
    ↓
Parse JSON response to DailyChecklistResponse model
    ↓
Extract template (id, name, description)
    ↓
Parse questions sections (each with items JSON string)
    ↓
Decode items JSON string to List<ChecklistItem>
    ↓
Store in controller.sections (observable list)
    ↓
UI renders sections with items
```

### 2. User Interaction Flow
```
User selects vehicle from dropdown
    ↓
controller.setSelectedVehicle(vehicleId)
    ↓
User answers question (e.g., "Yes" for boolean)
    ↓
controller.updateAnswer(sectionIndex, itemIndex, "Yes")
    ↓
Updates sections[sectionIndex].items[itemIndex].answer = "Yes"
    ↓
sections.refresh() → UI updates
    ↓
Progress bar updates
```

### 3. Submission Flow
```
User clicks Submit button
    ↓
controller.submitChecklist()
    ↓
Validate: vehicleId selected?
Validate: all mandatory questions answered?
    ↓
Get clockin_id from DriverDashboardController
    ↓
Build responses array:
  Loop through sections
    Loop through items
      If item.answer exists:
        Add {
          checklist_question_id: item.id,
          answer: item.answer,
          remarks: item.remarks
        }
    ↓
Prepare submission data:
{
  user_id: X,
  vehicle_id: X,
  checklist_template_id: template.id,
  clockin_id: X,
  responses: [...]
}
    ↓
ChecklistService.submitDailyChecklist()
    ↓
API POST /daily-checklist-submit
    ↓
Success → Refresh dashboard → Navigate back
```

---

## Comparison: Before vs After

### Before (Old Implementation)
```dart
// ❌ Unstructured data
final checklistData = Rxn<Map<String, dynamic>>();
final answers = <String, dynamic>{}.obs;

// ❌ Manual answer tracking
void updateAnswer(String questionId, dynamic value) {
  answers[questionId] = value;
}

// ❌ Raw data submission
await _checklistService.submitDailyChecklist(
  checklistData: answers,
  clockinId: clockinId,
);
```

### After (New Implementation)
```dart
// ✅ Strongly typed models
final checklistResponse = Rxn<DailyChecklistResponse>();
final sections = <ChecklistSection>[].obs;

// ✅ Structured answer tracking
void updateAnswer(int sectionIndex, int itemIndex, String answer, {String? remarks}) {
  sections[sectionIndex].items[itemIndex].answer = answer;
  sections.refresh();
}

// ✅ Structured submission
await _checklistService.submitDailyChecklist(
  vehicleId: selectedVehicleId.value!,
  checklistTemplateId: checklistResponse.value!.template.id,
  sections: sections,
  clockinId: clockinId,
);
```

---

## Benefits

### 1. Type Safety
- ✅ **Before**: `Map<String, dynamic>` - no compile-time checks
- ✅ **After**: Strongly typed models with validation

### 2. Data Structure
- ✅ **Before**: Flat key-value pairs
- ✅ **After**: Hierarchical sections → items structure

### 3. Progress Tracking
- ✅ **Before**: Manual calculation
- ✅ **After**: Built-in progress getters at section and overall level

### 4. Validation
- ✅ **Before**: Basic checks
- ✅ **After**: Mandatory field validation, completeness checks

### 5. API Compatibility
- ✅ **Before**: Custom data format
- ✅ **After**: Matches API contract exactly

### 6. Maintainability
- ✅ **Before**: Hard to understand data flow
- ✅ **After**: Clear models and transformations

---

## Example UI Usage

### Rendering Sections
```dart
ListView.builder(
  itemCount: controller.sections.length,
  itemBuilder: (context, sectionIndex) {
    final section = controller.sections[sectionIndex];
    
    return ExpansionTile(
      title: Text(section.title),
      subtitle: Text('${section.answeredItems}/${section.totalItems} completed'),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: section.items.length,
          itemBuilder: (context, itemIndex) {
            final item = section.items[itemIndex];
            
            if (item.isBoolean) {
              return _buildBooleanQuestion(sectionIndex, itemIndex, item);
            } else if (item.isText) {
              return _buildTextQuestion(sectionIndex, itemIndex, item);
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  },
);
```

### Boolean Question
```dart
Widget _buildBooleanQuestion(int sectionIndex, int itemIndex, ChecklistItem item) {
  return ListTile(
    title: Text(item.question),
    subtitle: item.isMandatory ? Text('* Required') : null,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChoiceChip(
          label: Text('Yes'),
          selected: item.answer == 'Yes',
          onSelected: (selected) {
            if (selected) {
              controller.updateAnswer(sectionIndex, itemIndex, 'Yes');
            }
          },
        ),
        SizedBox(width: 8),
        ChoiceChip(
          label: Text('No'),
          selected: item.answer == 'No',
          onSelected: (selected) {
            if (selected) {
              controller.updateAnswer(sectionIndex, itemIndex, 'No');
            }
          },
        ),
      ],
    ),
  );
}
```

### Progress Bar
```dart
LinearProgressIndicator(
  value: controller.progress,
  backgroundColor: Colors.grey[200],
  valueColor: AlwaysStoppedAnimation<Color>(
    controller.progress == 1.0 ? Colors.green : Colors.blue,
  ),
)
```

---

## Files Created/Modified

### Created:
1. ✅ `lib/app/data/models/checklist_model.dart`
   - ChecklistItem
   - ChecklistSection
   - ChecklistTemplate
   - DailyChecklistResponse
   - ChecklistResponse

### Modified:
2. ✅ `lib/app/data/services/checklist_service.dart`
   - getDailyChecklist() - Returns typed model
   - submitDailyChecklist() - Accepts structured data

3. ✅ `lib/app/modules/driver/checklist/daily_checklist_controller.dart`
   - Changed from Map to DailyChecklistResponse
   - Added sections list for user input
   - Added vehicle selection
   - Enhanced validation
   - Structured submission

4. ✅ `lib/app/modules/driver/dashboard/driver_dashboard_controller.dart`
   - Fixed duplicate methods
   - Fixed string escaping
   - Removed unused imports

---

## Testing Checklist

### API Integration
- [ ] GET /daily-checklist returns data correctly
- [ ] Data is parsed to DailyChecklistResponse model
- [ ] Sections and items are correctly extracted
- [ ] Field types (boolean, text) are recognized

### User Interaction
- [ ] Vehicle selection works
- [ ] Answering boolean questions updates state
- [ ] Answering text questions updates state
- [ ] Progress bar updates correctly
- [ ] Mandatory validation works

### Submission
- [ ] Submit button disabled when incomplete
- [ ] Submit button enabled when complete
- [ ] Clock in validation works (if clockin_id required)
- [ ] POST /daily-checklist-submit sends correct format
- [ ] Success message shows
- [ ] Dashboard refreshes after submit
- [ ] Navigates back to dashboard

---

## Summary

**Restructured Daily Checklist to:**
✅ Use strongly typed models (like Inspection)
✅ Parse dynamic API response structure
✅ Track progress at section and overall level
✅ Validate mandatory questions
✅ Submit in structured format matching API contract
✅ Include vehicle_id, checklist_template_id, clockin_id
✅ Build responses array dynamically from user input

The implementation now mirrors the Inspection feature with proper separation of concerns and type safety!
