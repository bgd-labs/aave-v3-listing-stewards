```diff
diff --git a/./reports/Optimism_permissions-pre-migration.md b/./reports/Optimism_permissions-post-migration.md
index 3f1b268..d5d6abc 100644
--- a/./reports/Optimism_permissions-pre-migration.md
+++ b/./reports/Optimism_permissions-post-migration.md
@@ -5,12 +5,12 @@
  | Owner of addresses provider | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | Owner of addresses provider registry | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | aclAdmin on addresses provider | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
- | Owner repay collateral adapter | **Guardian** ( 0xE50c8C619d05ff98b22Adf991F17602C774F785c ) | 
- | Owner swap collateral adapter | **Guardian** ( 0xE50c8C619d05ff98b22Adf991F17602C774F785c ) | 
+ | Owner repay collateral adapter | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
+ | Owner swap collateral adapter | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | Owner of wrapped weth gateway | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | Owner of Emission Manager | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
- | Owner of Controller of Collector | **Guardian** ( 0xE50c8C619d05ff98b22Adf991F17602C774F785c ) | 
- | Proxy admin of Collector | **Guardian** ( 0xE50c8C619d05ff98b22Adf991F17602C774F785c ) | 
+ | Owner of Controller of Collector | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
+ | Proxy admin of Collector | **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 ) | 
  | POOL_ADMIN |    **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 )  | 
  | EMERGENCY_ADMIN |   **Guardian** ( 0xE50c8C619d05ff98b22Adf991F17602C774F785c )   | 
  | DEFAULT_ADMIN_ROLE |    **Bridge Executor** ( 0x7d9103572bE58FfE99dc390E8246f02dcAe6f611 )  | 
```
