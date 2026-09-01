import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit'

class PermissionManager {
  async getPermission(permissions: Permissions[]) {
    const appInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    const manager = abilityAccessCtrl.createAtManager()
    let isHave = permissions.every(item => {
      let status = manager.checkAccessTokenSync(appInfo.appInfo.accessTokenId, item)
      return status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })
    if (isHave) {
      return true
    }
    const result = await manager.requestPermissionsFromUser(getContext(), permissions)
    let againHave = result.authResults.every(status => {
      return status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })

    if (againHave) {
      return true
    }
    const permissionSetting = await manager.requestPermissionOnSetting(getContext(), permissions)
    const have3 = permissionSetting.every((grantStatus) => {
      return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })
    return have3
  }

  async getPermissionOnce(permissions: Permissions[]) {
    const appInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    const manager = abilityAccessCtrl.createAtManager()
    let isHave = permissions.every(item => {
      let status = manager.checkAccessTokenSync(appInfo.appInfo.accessTokenId, item)
      return status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })
    if (isHave) {
      return true
    }
    const result = await manager.requestPermissionsFromUser(getContext(), permissions)
    let againHave = result.authResults.every(status => {
      return status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })

    return againHave
  }

  async getPermissionBySetting(permissions: Permissions[]) {
    const appInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    const manager = abilityAccessCtrl.createAtManager()
    let isHave = permissions.every(item => {
      let status = manager.checkAccessTokenSync(appInfo.appInfo.accessTokenId, item)
      return status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })
    if (isHave) {
      return true
    }

    const permissionSetting = await manager.requestPermissionOnSetting(getContext(), permissions)
    const have3 = permissionSetting.every((grantStatus) => {
      return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })
    return have3
  }

  checkPermission(permissions: Permissions) {
    const appInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    const manager = abilityAccessCtrl.createAtManager()
    let status = manager.checkAccessTokenSync(appInfo.appInfo.accessTokenId, permissions)
    return status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
  }
}

export const permissionManager = new PermissionManager()