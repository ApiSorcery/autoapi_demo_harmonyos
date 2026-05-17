# ApiSorcery - HarmonyOS Example

This is a HarmonyOS (OpenHarmony) application using ArkTS that demonstrates API integration using AutoAPI.

## Features

- ✅ User Management (CRUD operations)
- ✅ Search and Filter
- ✅ Pagination
- ✅ Form Validation
- ✅ Image Upload
- ✅ Status Management
- ✅ Type-safe API calls with AutoAPI
- ✅ Native HarmonyOS development with ArkTS

## Tech Stack

- **ArkTS** - TypeScript-based language for HarmonyOS
- **ArkUI** - Declarative UI framework
- **HarmonyOS SDK** - Native HarmonyOS APIs
- **HTTP Client** - Network requests
- **AutoAPI** - API code generation

## Prerequisites

- DevEco Studio (latest version)
- HarmonyOS SDK (API 9 or higher)
- Node.js >= 22.0.0 (for AutoAPI)
- HarmonyOS device or emulator

## Getting Started

### 1. Open Project in DevEco Studio

1. Open DevEco Studio
2. Select "Open Project"
3. Navigate to `autoapi_demo_harmonyos` directory
4. Wait for project sync to complete

### 2. Generate API Client Code

```bash
npm run swagger
```

This will generate ArkTS API client code from the OpenAPI specification.

### 3. Run the Application

1. Connect a HarmonyOS device or start an emulator
2. Click the "Run" button in DevEco Studio
3. Or use command line:
   ```bash
   hvigorw assembleHap
   ```

## Project Structure

```
autoapi_demo_harmonyos/
├── entry/
│   ├── src/
│   │   ├── main/
│   │   │   ├── ets/
│   │   │   │   ├── apis/          # Auto-generated API code
│   │   │   │   │   └── auto/
│   │   │   │   │       └── demo/
│   │   │   │   ├── pages/         # Application pages
│   │   │   │   │   └── user/      # User management pages
│   │   │   │   ├── components/    # Reusable components
│   │   │   │   ├── viewmodels/    # View models
│   │   │   │   ├── models/        # Data models
│   │   │   │   ├── utils/         # Utility functions
│   │   │   │   └── entryability/  # Entry ability
│   │   │   ├── resources/         # Resources
│   │   │   │   ├── base/
│   │   │   │   │   ├── element/   # Strings, colors
│   │   │   │   │   ├── media/     # Images
│   │   │   │   │   └── profile/   # Configurations
│   │   │   │   └── rawfile/       # Raw files
│   │   │   └── module.json5       # Module configuration
│   │   └── ohosTest/              # Tests
│   └── build-profile.json5        # Build configuration
├── AppScope/
│   ├── resources/                 # App-level resources
│   └── app.json5                  # App configuration
├── hvigor/                        # Build tool
├── oh_modules/                    # Dependencies
├── .apisorceryrc.json                # AutoAPI configuration
├── build-profile.json5            # Project build config
├── hvigorfile.ts                  # Build script
└── oh-package.json5               # Dependencies
```

## API Configuration

The application uses AutoAPI to generate type-safe API client code. Configuration is in `.apisorceryrc.json`:

```json
{
  "application": {
    "language": "arkts",
    "outputDir": "./entry/src/main/ets/apis/auto"
  },
  "servers": [
    {
      "code": "demo",
      "token": "your_token",
      "version": 3,
      "enabled": true,
      "source": "https://apisorcery.com/demo-api/swagger-json"
    }
  ]
}
```

## Dependencies

### Main Dependencies (oh-package.json5)

```json5
{
  "dependencies": {
    "@ohos/axios": "^2.0.0",           // HTTP client
    "@ohos/hypium": "1.0.21",          // Testing framework
    "@ohos/hamock": "1.0.0"            // Mock framework
  }
}
```

## Development

### ArkUI Declarative Syntax

ArkUI uses a declarative approach similar to SwiftUI and Jetpack Compose:

```typescript
@Entry
@Component
struct UserListPage {
  @State users: User[] = []
  @State isLoading: boolean = false
  
  aboutToAppear() {
    this.loadUsers()
  }
  
  build() {
    Column() {
      Text('User Management')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      
      if (this.isLoading) {
        LoadingProgress()
      } else {
        List() {
          ForEach(this.users, (user: User) => {
            ListItem() {
              UserListItem({ user: user })
            }
          })
        }
      }
    }
    .width('100%')
    .height('100%')
  }
  
  async loadUsers() {
    this.isLoading = true
    try {
      const response = await ApiUser.getUserPaged({
        pagination: { page: 1, limit: 10 }
      })
      this.users = response.results
    } catch (error) {
      console.error('Error loading users:', error)
    } finally {
      this.isLoading = false
    }
  }
}
```

### State Management

```typescript
@Observed
class UserViewModel {
  users: User[] = []
  isLoading: boolean = false
  
  async loadUsers() {
    this.isLoading = true
    try {
      const response = await ApiUser.getUserPaged({
        pagination: { page: 1, limit: 10 }
      })
      this.users = response.results
    } catch (error) {
      console.error('Error:', error)
    } finally {
      this.isLoading = false
    }
  }
}

@Entry
@Component
struct UserPage {
  @State viewModel: UserViewModel = new UserViewModel()
  
  aboutToAppear() {
    this.viewModel.loadUsers()
  }
  
  build() {
    // UI code
  }
}
```

### API Usage

```typescript
import { ApiUser } from '../apis/auto/demo/ApiUser'
import { UserAddRequest, UserModifyRequest } from '../apis/auto/demo/models'

// Get paginated user list
const response = await ApiUser.getUserPaged({
  pagination: { page: 1, limit: 10 },
  code: 'search-term'
})

// Create user
await ApiUser.addUser({
  code: 'user001',
  name: 'John Doe',
  email: 'john@example.com',
  status: true
} as UserAddRequest)

// Update user
await ApiUser.modifyUser({
  id: 1,
  name: 'Jane Doe',
  email: 'jane@example.com'
} as UserModifyRequest)

// Delete user
await ApiUser.removeUser({ id: 1 })
```

### Navigation

```typescript
import router from '@ohos.router'

// Navigate to user detail page
router.pushUrl({
  url: 'pages/user/UserDetailPage',
  params: {
    userId: user.id
  }
})

// Navigate back
router.back()

// Replace current page
router.replaceUrl({
  url: 'pages/HomePage'
})
```

### Network Requests

```typescript
import http from '@ohos.net.http'

// Create HTTP request
let httpRequest = http.createHttp()

httpRequest.request(
  'https://api.example.com/users',
  {
    method: http.RequestMethod.GET,
    header: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer token'
    }
  },
  (err, data) => {
    if (!err) {
      console.info('Result:' + data.result)
    } else {
      console.error('Error:' + JSON.stringify(err))
    }
    httpRequest.destroy()
  }
)
```

### Code Style

- Follow [ArkTS Coding Conventions](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkts-coding-conventions-0000001504769321)
- Use meaningful variable and function names
- Keep components small and focused
- Use TypeScript strict mode
- Prefer immutability

## Building for Production

### Debug Build
```bash
hvigorw assembleHap
```

### Release Build
```bash
hvigorw assembleHap --mode release
```

### Sign the HAP

1. Generate signing certificate in DevEco Studio
2. Configure signing in `build-profile.json5`:

```json5
{
  "app": {
    "signingConfigs": [
      {
        "name": "default",
        "type": "HarmonyOS",
        "material": {
          "certpath": "path/to/cert.cer",
          "storePassword": "password",
          "keyAlias": "alias",
          "keyPassword": "password",
          "profile": "path/to/profile.p7b",
          "signAlg": "SHA256withECDSA",
          "storeFile": "path/to/keystore.p12"
        }
      }
    ]
  }
}
```

## Testing

### Run Unit Tests
```bash
hvigorw test
```

### Unit Test Example

```typescript
import { describe, it, expect } from '@ohos/hypium'

describe('UserViewModel', () => {
  it('should load users successfully', async () => {
    const viewModel = new UserViewModel()
    await viewModel.loadUsers()
    
    expect(viewModel.users.length).toBeGreaterThan(0)
    expect(viewModel.isLoading).toBe(false)
  })
})
```

### UI Test Example

```typescript
import { Driver, ON } from '@ohos.UiTest'

describe('UserListPage', () => {
  it('should display user list', async () => {
    let driver = Driver.create()
    await driver.assertComponentExist(ON.text('User Management'))
    await driver.assertComponentExist(ON.type('List'))
  })
})
```

## Deployment

### HarmonyOS App Gallery

1. Build release HAP:
   ```bash
   hvigorw assembleHap --mode release
   ```

2. Sign the HAP with your certificate

3. Upload to AppGallery Connect:
   - Go to AppGallery Connect
   - Select your app
   - Navigate to Distribution > Version Information
   - Upload the signed HAP
   - Complete app information
   - Submit for review

### App Signing

HarmonyOS requires app signing for distribution:

1. **Development Certificate**: For testing on devices
2. **Distribution Certificate**: For AppGallery distribution

Generate certificates in DevEco Studio or AppGallery Connect.

## Troubleshooting

### Common Issues

1. **Build Failed**
   ```bash
   hvigorw clean
   hvigorw assembleHap
   ```

2. **Dependency Issues**
   ```bash
   rm -rf oh_modules
   ohpm install
   ```

3. **Device Connection Issues**
   - Enable developer mode on device
   - Check USB debugging is enabled
   - Verify device is recognized: `hdc list targets`

4. **API Connection Issues**
   - Add internet permission in `module.json5`
   - Check network security configuration
   - Verify API base URL

### Permissions

Add required permissions in `entry/src/main/module.json5`:

```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      },
      {
        "name": "ohos.permission.GET_NETWORK_INFO"
      },
      {
        "name": "ohos.permission.READ_MEDIA"
      },
      {
        "name": "ohos.permission.WRITE_MEDIA"
      },
      {
        "name": "ohos.permission.CAMERA"
      }
    ]
  }
}
```

### Network Configuration

For development, configure network security in `module.json5`:

```json5
{
  "module": {
    "networkConfig": {
      "cleartextTraffic": true
    }
  }
}
```

## Performance Optimization

### Tips

1. **Use @Reusable decorator** for frequently created components
2. **Implement LazyForEach** for long lists
3. **Use @ObjectLink** for nested state management
4. **Profile with DevEco Profiler** to identify bottlenecks
5. **Enable code obfuscation** for release builds

### Memory Management

```typescript
// Use @Reusable for component reuse
@Reusable
@Component
struct UserListItem {
  @State user: User = null
  
  aboutToReuse(params: Record<string, Object>) {
    this.user = params.user as User
  }
  
  build() {
    // UI code
  }
}
```

## Resources

### Official Documentation
- [HarmonyOS Documentation](https://developer.harmonyos.com/)
- [ArkTS Documentation](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkts-get-started-0000001504769321)
- [ArkUI Documentation](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkui-overview-0000001532857845)

### Development Tools
- [DevEco Studio](https://developer.harmonyos.com/cn/develop/deveco-studio)
- [HDC (HarmonyOS Device Connector)](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/hdc-0000001050166905)

### Community
- [HarmonyOS Developer Forum](https://developer.huawei.com/consumer/cn/forum/home)
- [OpenHarmony](https://gitee.com/openharmony)

## Version Information

- HarmonyOS SDK: API 9+
- ArkTS: Latest
- DevEco Studio: Latest
- AutoAPI: Latest

## License

MIT
