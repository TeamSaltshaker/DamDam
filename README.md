# [담담](https://apps.apple.com/app/id6747020819)

![담담](https://github.com/user-attachments/assets/3aae2120-865a-4932-b78d-96378af1cd6f)

![담담소개](https://github.com/user-attachments/assets/47269e06-40af-4bc4-bebe-4055942cc347)

![담담](https://github.com/user-attachments/assets/8ac332fe-72a0-4b00-805c-462ddc13eef4)

# 역할 분담
<table>
  <thead>
    <tr>
      <th><a href="https://github.com/youseokhwan">youseokhwan</a></th>
      <th><a href="https://github.com/dbguswls030">dbguswls030</a></th>
      <th><a href="https://github.com/meowbutlerdev">meowbutlerdev</a></th>
      <th><a href="https://github.com/gnoes-ios">gnoes-ios</a></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <ul>
          <li>폴더 화면</li>
          <li>CoreData 구축</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>클립 추가, 수정 화면</li>
          <li>Share Extension</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>클립 상세 화면</li>
          <li>폴더 추가, 수정 화면</li>
          <li>폴더 추가 화면</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>홈 화면</li>
          <li>방문하지 않은 클립 목록 화면</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

# 기술 스택 및 아키텍처
<table>
  <thead>
    <tr>
      <th>범주</th>
      <th>기술 스택</th>
      <th>선택 이유</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="2">UI 구성</td>
      <td><ul><li>SnapKit</li></ul></td>
      <td>코드 기반 레이아웃을 간결하게 구성</td>
    </tr>
    <tr>
      <td>
        <ul>
          <li>UICollectionView</li>
          <li>Compositional Layout</li>
          <li>DiffableDataSource</li>
          <li>ListConfiguration</li>
        </ul>
      </td>
      <td>폴더/클립의 리스트 UI를 유연하고 효율적으로 구성</td>
    </tr>
    <tr>
      <td rowspan="2">비동기 처리</td>
      <td>
        <ul>
          <li>RxSwift</li>
          <li>ReactorKit</li>
        </ul>
      </td>
      <td>복잡한 UI 이벤트 흐름을 명확하게 분리하고 처리</td>
    </tr>
    <tr>
      <td><ul><li>async/await</li></ul></td>
      <td>네트워크/비동기 작업의 가독성과 오류 처리를 개선</td>
    </tr>
    <tr>
      <td>이미지 처리</td>
      <td><ul><li>Kingfisher</li></ul></td>
      <td>썸네일 이미지를 효율적으로 캐싱하고 로딩</td>
    </tr>
    <tr>
      <td>데이터 저장</td>
      <td><ul><li>CoreData</li></ul></td>
      <td>앱 종료 후에도 클립 정보를 안정적으로 보관</td>
    </tr>
    <tr>
      <td>아키텍처</td>
      <td>
        <ul>
          <li>MVVM</li>
          <li>Clean Architecture</li>
        </ul>
      </td>
      <td>역할을 명확히 나눠 유지보수성과 테스트 용이성 상승</td>
    </tr>
  </tbody>
</table>

# 프로젝트 구조
```bash
Root
├── Clipster
│   ├── App
│   │   ├── Coordinator
│   │   │   ├── App
│   │   │   └── Protocol
│   │   ├── Derived
│   │   ├── DIContainer
│   │   ├── Resource
│   │   └── Source
│   │
│   ├── Data
│   │   ├── DTO
│   │   ├── Error
│   │   ├── Model
│   │   ├── Persistence
│   │   ├── Protocol
│   │   ├── Repository
│   │   └── Util
│   │
│   ├── Domain
│   │   ├── Error
│   │   ├── Model
│   │   ├── Protocol
│   │   └── UseCase
│   │
│   └── Presentation
│       ├── Coordinator
│       ├── Model
│       ├── Resource
│       ├── Scene
│       │   ├── ClipDetail
│       │   ├── Common
│       │   ├── EditClip
│       │   ├── EditFolder
│       │   ├── Folder
│       │   ├── FolderSelector
│       │   ├── Home
│       │   └── UnvisitedClipList
│       └── Util
│           ├── Extension
│           └── Mapper
└── ShareExtension
```

# CoreData 구조

![image](https://github.com/user-attachments/assets/6f23ee8e-c5fd-4165-acff-67655822beac)
