```diff
diff --git a/./reports/Arbitrum_permissions-pre-migration.md b/./reports/Arbitrum_permissions-post-migration.md
index dcffb56..2ae4d78 100644
--- a/./reports/Arbitrum_permissions-pre-migration.md
+++ b/./reports/Arbitrum_permissions-post-migration.md
@@ -2,15 +2,15 @@
 
 | Permission | Who? |
 |---|---|
- | Owner of addresses provider | **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb ) | 
- | Owner of addresses provider registry | **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb ) | 
- | aclAdmin on addresses provider | **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb ) | 
+ | Owner of addresses provider | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
+ | Owner of addresses provider registry | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
+ | aclAdmin on addresses provider | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | Owner repay collateral adapter | **Deployer Account** ( 0x4365F8e70CF38C6cA67DE41448508F2da8825500 ) | 
  | Owner swap collateral adapter | **Deployer Account** ( 0x4365F8e70CF38C6cA67DE41448508F2da8825500 ) | 
- | Owner of wrapped weth gateway | **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb ) | 
- | Owner of Emission Manager | **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb ) | 
- | POOL_ADMIN |   **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb )  **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 )  | 
+ | Owner of wrapped weth gateway | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
+ | Owner of Emission Manager | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
+ | POOL_ADMIN |    **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 )  | 
  | EMERGENCY_ADMIN |   **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb )   | 
- | DEFAULT_ADMIN_ROLE |   **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb )   | 
+ | DEFAULT_ADMIN_ROLE |    **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 )  | 
 
 
```
