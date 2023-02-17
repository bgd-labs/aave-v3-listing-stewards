```diff
diff --git a/./reports/Arbitrum_permissions-pre-migration.md b/./reports/Arbitrum_permissions-post-migration.md
index 94edfc3..c4bcf9e 100644
--- a/./reports/Arbitrum_permissions-pre-migration.md
+++ b/./reports/Arbitrum_permissions-post-migration.md
@@ -5,12 +5,12 @@
  | Owner of addresses provider | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | Owner of addresses provider registry | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | aclAdmin on addresses provider | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
- | Owner repay collateral adapter | **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb ) | 
- | Owner swap collateral adapter | **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb ) | 
+ | Owner repay collateral adapter | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
+ | Owner swap collateral adapter | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | Owner of wrapped weth gateway | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | Owner of Emission Manager | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
- | Owner of Controller of Collector | **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb ) | 
- | Proxy admin of Collector | **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb ) | 
+ | Owner of Controller of Collector | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
+ | Proxy admin of Collector | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | POOL_ADMIN |    **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 )  | 
  | EMERGENCY_ADMIN |   **Guardian** ( 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb )   | 
  | DEFAULT_ADMIN_ROLE |    **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 )  | 
```