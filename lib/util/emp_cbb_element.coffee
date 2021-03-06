emp = require '../exports/emp'
fs = require 'fs'
path = require 'path'
fs_plus = require 'fs-plus'
tmp_alert_title = "提示"
tmp_alert_msg = "插件侦测到存在之前参与的模板配置, 是否使用之前的模板配置?"

module.exports =
class EmpCbbEle

  name:null
  ver: emp.EMP_DEFAULT_VER
  desc: null
  type: emp.EMP_DEFAULT_TYPE
  own_package: emp.EMP_DEFAULT_PACKAGE
  logo: null
  html: null
  css: null
  lua: null
  available: true
  detail_image: null
  package_path: null
  element_path: null
  ele_json:null
  lv:emp.EMP_JSON_ELE

  constructor: (@name, @desc, @logo, @type, tmp_pack, @detail_image, @src_list)->
    # console.log @name
    # console.log @desc
    # console.log @logo
    # console.log @type
    # console.log tmp_pack
    # console.log @detail_image
    # console.log @src_list
    # console.log "constructor a new emp cbb element"
    # if !tmp_pack
    #   @check_cbb_name()
    # else
    @own_package = tmp_pack
    @template_path = atom.project.templates_path

  refresh: ->
    temp_str = JSON.stringify @get_json(), null, '\t'
    fs.writeFileSync @template_json, temp_str

  # element information
  get_info: ->
    {name:@name, version:@ver, element_path:@element_path_rel, desc: @desc,
    type: @type, logo:@logo, detail:@img_list_rel}

  # element json content
  get_json: ->
    if !@ele_json
      @ele_json = {name:@name, version:@ver, desc: @desc,
      type: @type, logo:@logo, html:@html, lua:@lua, #css:@css,
      available:@available, own_package: @own_package,
      source:@src_list_rel,detail:@img_list_rel,
      element_path:@element_path_rel, level:@lv}
    else
      @ele_json

  #  判断控件名称, 如果控件名称为 atom textarea, 则第一个空格前为大分类
  #  前提是大分类已经存在
  check_cbb_name: () ->
    re_cbb = @name.split ' '
    re_len = re_cbb.length
    if re_len > 1
      @own_package = re_cbb[0]
      re_cbb.shift()
      @name = re_cbb.join ' '
    # {root:root_name, name:re_name}

  create: (@package_path, @own_package)->
        # {name:cbb_name, version:emp.EMP_DEFAULT_VER, path:null, desc: cbb_desc,
        # type: cbb_type, logo:{type:emp.EMP_FILE_TYPE, con:cbb_logo}, html:{type:emp.EMP_CON_TYPE, con:ccb_con}, css:null, lua:null, available:true}

    @element_path = path.join @package_path, @type, @name
    @element_path_rel = path.join @own_package, @type, @name
    emp.mkdir_sync_safe @element_path
    @template_json = path.join @element_path, emp.EMP_TEMPLATE_JSON

    if fs.existsSync @template_json
      return_flag = emp.show_alert(tmp_alert_title, tmp_alert_msg)

      if return_flag
        json_con = fs.readFileSync @template_json
        tmp_obj = JSON.parse json_con
        @name = tmp_obj.name
        @desc = tmp_obj.desc
        @type = tmp_obj.type
        @logo = tmp_obj.logo
        @detail = tmp_obj.detail
        @element_path = tmp_obj.element_path
        @html = tmp_obj.html
        # @css = tmp_obj.css
        @lua = tmp_obj.lua
        @available = tmp_obj.available
        @own_package = tmp_obj.own_package
        @source = tmp_obj.source
        @level = tmp_obj.level

        @available = tmp_obj.available
        @available = tmp_obj.available
        @available = tmp_obj.available
        @available = tmp_obj.available

      else
        @template_json_rel = path.join @element_path_rel, emp.EMP_TEMPLATE_JSON
        @format_template()
        @refresh()
    else
      @template_json_rel = path.join @element_path_rel, emp.EMP_TEMPLATE_JSON
      @format_template()
      @refresh()

  edit: (@package_path, @own_package, @old_obj)->
    @element_path = path.join @package_path, @type, @name
    @element_path_rel = path.join @own_package, @type, @name
    @template_json = path.join @element_path, emp.EMP_TEMPLATE_JSON
    @template_json_rel = path.join @element_path_rel, emp.EMP_TEMPLATE_JSON
    @del_files()
    @format_template()
    @refresh()

  del_files:() ->
    console.log @del_source_files
    console.log @del_image_detail
    for tmp_file in @del_source_files
      fs_plus.removeSync(tmp_file) unless !fs.existsSync tmp_file
    for tmp_file in @del_image_detail
      fs_plus.removeSync(tmp_file) unless !fs.existsSync tmp_file

  format_template_edit: () ->

    if @logo
      @logo = @copy_content_ch @logo
    if @html?.type is emp.EMP_FILE_TYPE
      @html.body = @copy_content_ch @html.body

    # if @css?.type is emp.EMP_FILE_TYPE
    #   @css.body = @copy_content_ch path.join @template_path, @css.body
    if @lua?.type is emp.EMP_FILE_TYPE
      @lua.body = @copy_content_ch path.join @template_path, @lua.body

    @img_list_rel = []
    if @detail_image
      for tmp_file in @detail_image
        @img_list_rel.push @copy_content_ch tmp_file

    @src_list_rel = []
    # console.log @src_list
    if @src_list
      for tmp_file in @src_list
        @src_list_rel.push @copy_content_ch(tmp_file, emp.EMP_IMG_DIR)


  format_template: () ->
    if @logo
      @logo = @copy_content_ch @logo
    if @html?.type is emp.EMP_FILE_TYPE
      @html.body = @copy_content_ch @html.body

    # if @css?.type is emp.EMP_FILE_TYPE
    #   @css.body = @copy_content_ch @css.body
    if @lua?.type is emp.EMP_FILE_TYPE
      @lua.body = @copy_content_ch @lua.body

    @img_list_rel = []
    if @detail_image
      for tmp_file in @detail_image
        @img_list_rel.push @copy_content_ch tmp_file

    @src_list_rel = []
    if @src_list
      for tmp_file in @src_list
        @src_list_rel.push @copy_content_ch(tmp_file, emp.EMP_IMG_DIR)


  copy_content_ch: (f_path, add_path="") ->
    # console.log t_path
    # console.log f_path
    to_path = path.join @element_path, add_path
    to_path_rel = path.join @element_path_rel, add_path
    # console.log to_path
    emp.mkdir_sync(to_path)
    f_name = path.basename f_path
    f_con = fs.readFileSync f_path
    re_file = path.join to_path, f_name
    re_file_rel = path.join to_path_rel, f_name
    # force copy
    fs.writeFileSync re_file, f_con  #unless fs.existsSync(re_file)#, 'utf8'
    re_file_rel

  set_con: (tmp_con, ctype) ->
    tmp_obj = @new_con_obj(tmp_con)
    switch ctype
      when emp.EMP_QHTML then @html = tmp_obj
      # when emp.EMP_QCSS then @css = tmp_obj
      when emp.EMP_QLUA then @lua = tmp_obj

  set_file: (tmp_file, ctype) ->
    unless !tmp_file
      tmp_obj = @new_file_obj(tmp_file)
      switch ctype
        when emp.EMP_QHTML then @html = tmp_obj
        # when emp.EMP_QCSS then @css = tmp_obj
        when emp.EMP_QLUA then @lua = tmp_obj

  set_edit_con: (tmp_con, ctype, def_type) ->
    if def_type is emp.EMP_CON_TYPE
      tmp_obj = @new_con_obj(tmp_con)
    else
      tmp_obj = @new_file_obj(tmp_con)

    switch ctype
      when emp.EMP_QHTML then @html = tmp_obj
      # when emp.EMP_QCSS then @css = tmp_obj
      when emp.EMP_QLUA then @lua = tmp_obj

  set_del_files: (@del_source_files, @del_image_detail)->


  new_con_obj:(tmp_con) ->
    {type:emp.EMP_CON_TYPE, body:tmp_con}

  new_file_obj:(tmp_file) ->
    {type:emp.EMP_FILE_TYPE, body:tmp_file}
