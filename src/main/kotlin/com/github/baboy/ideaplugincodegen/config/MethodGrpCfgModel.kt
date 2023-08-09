package com.github.baboy.ideaplugincodegen.config

/**
 *
 * @author zhangyinghui
 * @date 2023/8/4
 */
class MethodGrpCfgModel {
    var uri: CodeCfg.UriCfg? = null
   var ctrl: MethodCfgModel? = null
   var svc: MethodCfgModel? = null
   var dao: MethodCfgModel? = null

    class MethodCfgModel: CodeCfg.MethodCfg(){
        var fields: List<String>? = null
        var className:String? = null
    }
}