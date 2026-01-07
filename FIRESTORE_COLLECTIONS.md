# Firebase Firestore Collections Structure

This document describes the Firestore database structure for the ResQ application.

## Overview

The application uses Firebase Firestore as the primary cloud database for storing user data. Local storage (Hive) is used as a cache for offline access.

## Collections Structure

### 1. Users Collection

**Path:** `users/{userId}`

Each authenticated user has a document in the `users` collection. The document ID is the Firebase Auth UID.

#### User Document Structure

```json
{
  "email": "user@example.com",
  "name": "User Name",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

**Fields:**
- `email` (string, required): User's email address
- `name` (string, optional): User's display name
- `createdAt` (timestamp, required): Account creation timestamp
- `updatedAt` (timestamp, required): Last update timestamp

---

### 2. Emergency Contacts Subcollection

**Path:** `users/{userId}/emergency_contacts/{contactId}`

Each user can have up to 5 emergency contacts stored in a subcollection under their user document.

#### Emergency Contact Document Structure

```json
{
  "name": "John Doe",
  "phoneNumber": "+1234567890",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

**Fields:**
- `name` (string, required): Contact's name
- `phoneNumber` (string, required): Contact's phone number (format: +[country code][number])
- `createdAt` (timestamp, required): When the contact was added
- `updatedAt` (timestamp, required): Last update timestamp

**Constraints:**
- Maximum 5 contacts per user
- Contacts are ordered by `createdAt` in descending order (newest first)

---

## Security Rules

### Recommended Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Users can only read/write their own document
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Emergency contacts subcollection
      match /emergency_contacts/{contactId} {
        // Users can only manage their own emergency contacts
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
        // Validate contact data
        allow create: if request.auth != null 
          && request.auth.uid == userId
          && request.resource.data.keys().hasAll(['name', 'phoneNumber', 'createdAt', 'updatedAt'])
          && request.resource.data.name is string
          && request.resource.data.phoneNumber is string
          && request.resource.data.name.size() > 0
          && request.resource.data.phoneNumber.size() >= 10;
      }
    }
  }
}
```

---

## Data Flow

### Reading Emergency Contacts

1. **Primary:** Fetch from Firestore (`users/{userId}/emergency_contacts`)
2. **Cache:** Store in local Hive storage for offline access
3. **Fallback:** If Firestore fails, read from local cache

### Writing Emergency Contacts

1. **Primary:** Write to Firestore first (source of truth)
2. **Cache:** Update local Hive storage
3. **Offline:** If Firestore fails, save to local cache and sync when online

### Deleting Emergency Contacts

1. **Primary:** Delete from Firestore using document ID
2. **Cache:** Remove from local Hive storage
3. **Offline:** If Firestore fails, delete from local cache and sync when online

---

## Indexes

### Required Firestore Indexes

The following composite index is required for efficient queries:

**Collection:** `users/{userId}/emergency_contacts`
- Fields: `createdAt` (Descending)

This index is automatically created by Firestore when you run the query, or you can create it manually in the Firebase Console.

---

## Migration Notes

### From Local-Only to Firestore

If you have existing users with local-only emergency contacts:

1. On first app launch after update, sync local contacts to Firestore
2. After successful sync, local storage becomes a cache only
3. Future operations prioritize Firestore

### Data Consistency

- Firestore is the **source of truth**
- Local storage is a **cache** for offline access
- On login, local cache is synced with Firestore
- On logout, local cache is cleared

---

## Best Practices

1. **Always validate data** before writing to Firestore
2. **Handle offline scenarios** gracefully with local cache
3. **Implement retry logic** for failed Firestore operations
4. **Monitor Firestore usage** to stay within free tier limits
5. **Use batch operations** when deleting multiple contacts
6. **Implement proper error handling** for network failures

---

## Collection Paths Summary

| Collection Path | Description | Max Items |
|----------------|-------------|-----------|
| `users/{userId}` | User profile data | 1 per user |
| `users/{userId}/emergency_contacts/{contactId}` | User's emergency contacts | 5 per user |

---

## Example Queries

### Get all emergency contacts for a user (ordered by creation date)

```dart
final snapshot = await firestore
    .collection('users/$userId/emergency_contacts')
    .orderBy('createdAt', descending: true)
    .get();
```

### Add a new emergency contact

```dart
await firestore
    .collection('users/$userId/emergency_contacts')
    .add({
      'name': 'John Doe',
      'phoneNumber': '+1234567890',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
```

### Delete an emergency contact

```dart
await firestore
    .collection('users/$userId/emergency_contacts')
    .doc(contactId)
    .delete();
```

---

### 3. Dangerous Zones Collection

**Path:** `dangerous_zones/{zoneId}`

Dangerous zones marked by users on the map. These zones are visible to all users and automatically expire after 24 hours.

#### Dangerous Zone Document Structure

```json
{
  "userId": "user123",
  "userName": "John Doe",
  "name": "Flood Area",
  "type": "polygon",
  "polygonPoints": [
    {"latitude": 33.6844, "longitude": 73.0479},
    {"latitude": 33.6850, "longitude": 73.0485},
    {"latitude": 33.6840, "longitude": 73.0490}
  ],
  "center": null,
  "radius": null,
  "createdAt": "2024-01-01T00:00:00Z",
  "expiresAt": "2024-01-02T00:00:00Z"
}
```

**Fields:**
- `userId` (string, required): ID of the user who created the zone
- `userName` (string, required): Name of the user who created the zone
- `name` (string, required): Name/description of the dangerous zone
- `type` (string, required): Either "polygon" or "circle"
- `polygonPoints` (array, optional): Array of {latitude, longitude} objects for polygon type
- `center` (object, optional): {latitude, longitude} for circle type
- `radius` (number, optional): Radius in meters for circle type
- `createdAt` (timestamp, required): When the zone was created
- `expiresAt` (timestamp, required): When the zone expires (24 hours after creation)

**Constraints:**
- Zones automatically expire after 24 hours
- Users can delete their own zones
- All users can view all active zones
- Polygon must have at least 3 points
- Circle must have center and radius > 0

**Security Rules:**
```javascript
match /dangerous_zones/{zoneId} {
  // Anyone authenticated can read active zones
  allow read: if request.auth != null;
  
  // Anyone authenticated can create zones
  allow create: if request.auth != null
    && request.resource.data.userId == request.auth.uid
    && request.resource.data.keys().hasAll(['userId', 'userName', 'name', 'type', 'createdAt', 'expiresAt']);
  
  // Only the creator can delete their zone
  allow delete: if request.auth != null && resource.data.userId == request.auth.uid;
  
  // No updates allowed (zones are immutable)
  allow update: if false;
}
```

---

## Future Enhancements

Potential additions to the Firestore structure:

1. **User Preferences Collection:** Store user settings
   - Path: `users/{userId}/preferences`
   
2. **Emergency History Collection:** Track emergency SMS sent
   - Path: `users/{userId}/emergency_history/{historyId}`

