export interface IChannelResponse<T> {
  code: number
  msg: string
  data: T
}

export interface IDevice {
  androidId: string
  oId: string
  haid?: string
  odid?: string
  brand?: string
  model?: string
  sysVersion?: string
}
