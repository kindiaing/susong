#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
根据 PRD/FSD 生成本地速送系统各模块 drawio 流程图。
每个 .drawio 文件包含一个可导入 diagrams.net / draw.io 的 mxGraphModel XML。
"""
import os
from xml.etree.ElementTree import Element, SubElement, tostring

OUT_DIR = "docs/flowcharts"


def xml_declaration():
    return '<?xml version="1.0" encoding="UTF-8"?>'


def make_mxfile(diagram_name: str, graph_model_xml: str) -> str:
    return (
        xml_declaration()
        + f'<mxfile host="app.diagrams.net" modified="2026-07-25T00:00:00.000Z" '
        + f'agent="local-script" etag="{diagram_name}" version="22.1.0" type="device">'
        + f'<diagram name="{diagram_name}" id="{diagram_name}">'
        + graph_model_xml
        + "</diagram></mxfile>"
    )


def make_graph_model(cells: list) -> str:
    header = (
        '<mxGraphModel dx="1434" dy="780" grid="1" gridSize="10" guides="1" '
        'tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" '
        'pageWidth="1600" pageHeight="1200" math="0" shadow="0">'
    )
    root = '<root><mxCell id="0" /><mxCell id="1" parent="0" />'
    body = "".join(cells)
    footer = "</root></mxGraphModel>"
    return header + root + body + footer


def rect_node(_id: str, x: int, y: int, w: int, h: int, text: str,
              fill: str = "#E1F5FE", stroke: str = "#01579B") -> str:
    style = (
        f"rounded=1;whiteSpace=wrap;html=1;fillColor={fill};"
        f"strokeColor={stroke};fontSize=12;fontFamily=Helvetica;"
        "verticalAlign=middle;align=center;"
    )
    return (
        f'<mxCell id="{_id}" value="{text}" style="{style}" vertex="1" parent="1">'
        f'<mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry" />'
        f'</mxCell>'
    )


def diamond_node(_id: str, x: int, y: int, w: int, h: int, text: str,
                 fill: str = "#FFF9C4", stroke: str = "#F57F17") -> str:
    style = (
        f"rhombus;whiteSpace=wrap;html=1;fillColor={fill};"
        f"strokeColor={stroke};fontSize=12;fontFamily=Helvetica;"
        "verticalAlign=middle;align=center;"
    )
    return (
        f'<mxCell id="{_id}" value="{text}" style="{style}" vertex="1" parent="1">'
        f'<mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry" />'
        f'</mxCell>'
    )


def oval_node(_id: str, x: int, y: int, w: int, h: int, text: str,
              fill: str = "#C8E6C9", stroke: str = "#2E7D32") -> str:
    style = (
        f"ellipse;whiteSpace=wrap;html=1;fillColor={fill};"
        f"strokeColor={stroke};fontSize=12;fontFamily=Helvetica;"
        "verticalAlign=middle;align=center;"
    )
    return (
        f'<mxCell id="{_id}" value="{text}" style="{style}" vertex="1" parent="1">'
        f'<mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry" />'
        f'</mxCell>'
    )


def edge(_id: str, source: str, target: str, label: str = "") -> str:
    style = (
        "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;"
        "jettySize=auto;html=1;strokeColor=#666666;fontSize=11;"
    )
    if label:
        style += f"labelBackgroundColor=#ffffff;"
    return (
        f'<mxCell id="{_id}" value="{label}" style="{style}" edge="1" '
        f'parent="1" source="{source}" target="{target}">'
        f'<mxGeometry relative="1" as="geometry" />'
        f'</mxCell>'
    )


def save(filename: str, diagram_name: str, cells: list):
    xml = make_mxfile(diagram_name, make_graph_model(cells))
    path = os.path.join(OUT_DIR, filename)
    with open(path, "w", encoding="utf-8") as f:
        f.write(xml)
    print(f"[OK] {path}")


# -----------------------------
# 1. 整体系统业务架构图
# -----------------------------
def overall_architecture():
    cells = []
    # 三端
    cells.append(rect_node("2", 40, 40, 140, 60, "微信小程序商家端\n（商家下单）", "#E3F2FD", "#1565C0"))
    cells.append(rect_node("3", 220, 40, 140, 60, "管理后台 Web 端\n（运营/财务/仓库）", "#E3F2FD", "#1565C0"))
    cells.append(rect_node("4", 400, 40, 140, 60, "微信小程序司机端\n（配送签收）", "#E3F2FD", "#1565C0"))
    # API / 服务层
    cells.append(rect_node("5", 180, 140, 220, 60, "Laravel API 服务层\n（Sanctum 认证 / 业务逻辑）", "#FFF3E0", "#E65100"))
    # 数据层
    cells.append(rect_node("6", 120, 240, 120, 60, "MySQL 8.0\n主数据库", "#F3E5F5", "#6A1B9A"))
    cells.append(rect_node("7", 260, 240, 120, 60, "Redis\n缓存+队列+会话", "#F3E5F5", "#6A1B9A"))
    cells.append(rect_node("8", 400, 240, 120, 60, "异步队列\n消息/报表/推送", "#F3E5F5", "#6A1B9A"))
    # 外部服务
    cells.append(rect_node("9", 120, 340, 120, 60, "腾讯地图 API\n轨迹/导航/线路", "#E0F2F1", "#00695C"))
    cells.append(rect_node("10", 260, 340, 120, 60, "微信支付\n充值/结算", "#E0F2F1", "#00695C"))
    cells.append(rect_node("11", 400, 340, 120, 60, "OSS/本地存储\n图片/凭证", "#E0F2F1", "#00695C"))

    # edges
    cells.append(edge("e1", "2", "5"))
    cells.append(edge("e2", "3", "5"))
    cells.append(edge("e3", "4", "5"))
    cells.append(edge("e4", "5", "6"))
    cells.append(edge("e5", "5", "7"))
    cells.append(edge("e6", "5", "8"))
    cells.append(edge("e7", "5", "9"))
    cells.append(edge("e8", "5", "10"))
    cells.append(edge("e9", "5", "11"))
    save("01_整体系统业务架构图.drawio", "整体系统业务架构图", cells)


# -----------------------------
# 2. 平台统采流程
# -----------------------------
def procurement_flow():
    cells = []
    cells.append(oval_node("2", 340, 20, 120, 50, "开始", "#C8E6C9", "#2E7D32"))
    cells.append(rect_node("3", 320, 100, 160, 60, "汇总订单需求\n自动生成待采清单"))
    cells.append(rect_node("4", 320, 190, 160, 60, "运营确认/手工添加\n待采商品与数量"))
    cells.append(rect_node("5", 320, 280, 160, 60, "生成采购单\n自动匹配供应商"))
    cells.append(rect_node("6", 320, 370, 160, 60, "供应商接单"))
    cells.append(rect_node("7", 320, 460, 160, 60, "供应商备货中"))
    cells.append(rect_node("8", 320, 550, 160, 60, "供应商已发货"))
    cells.append(rect_node("9", 320, 640, 160, 60, "采购入库\n核对数量/金额"))
    cells.append(diamond_node("10", 340, 730, 120, 70, "入库是否一致？"))
    cells.append(rect_node("11", 500, 740, 140, 50, "记录入库差异", "#FFCCBC", "#BF360C"))
    cells.append(rect_node("12", 320, 830, 160, 60, "库存联动\n更新仓库库存"))
    cells.append(oval_node("13", 340, 920, 120, 50, "完成", "#C8E6C9", "#2E7D32"))

    cells.append(edge("e1", "2", "3"))
    cells.append(edge("e2", "3", "4"))
    cells.append(edge("e3", "4", "5"))
    cells.append(edge("e4", "5", "6"))
    cells.append(edge("e5", "6", "7"))
    cells.append(edge("e6", "7", "8"))
    cells.append(edge("e7", "8", "9"))
    cells.append(edge("e8", "9", "10"))
    cells.append(edge("e9", "10", "11", "否"))
    cells.append(edge("e10", "11", "12"))
    cells.append(edge("e11", "10", "12", "是"))
    cells.append(edge("e12", "12", "13"))
    save("02_平台统采流程.drawio", "平台统采流程", cells)


# -----------------------------
# 3. 客户直采流程（商家下单）
# -----------------------------
def merchant_order_flow():
    cells = []
    cells.append(oval_node("2", 340, 20, 120, 50, "开始", "#C8E6C9", "#2E7D32"))
    cells.append(rect_node("3", 320, 90, 160, 60, "商家浏览/搜索商品\n智能推荐/常购清单"))
    cells.append(rect_node("4", 320, 170, 160, 60, "加入购物车\n选择规格/数量"))
    cells.append(rect_node("5", 320, 250, 160, 60, "选择配送地址\n选择批次（上午/下午）"))
    cells.append(rect_node("6", 320, 330, 160, 60, "提交订单\n余额/账期/现结"))
    cells.append(diamond_node("7", 340, 410, 120, 70, "支付/账期是否通过？"))
    cells.append(rect_node("8", 520, 420, 140, 50, "提示支付失败\n或余额不足", "#FFCCBC", "#BF360C"))
    cells.append(rect_node("9", 320, 510, 160, 60, "订单待拣货"))
    cells.append(rect_node("10", 320, 590, 160, 60, "创建拣货任务\n分配拣货员"))
    cells.append(rect_node("11", 320, 670, 160, 60, "拣货执行\n称重改价/差异记录"))
    cells.append(rect_node("12", 320, 750, 160, 60, "创建配送任务\n分配司机/车辆"))
    cells.append(rect_node("13", 320, 830, 160, 60, "司机配送中\n轨迹实时上报"))
    cells.append(rect_node("14", 320, 910, 160, 60, "商家签收确认\n拍照/电子签名"))
    cells.append(diamond_node("15", 340, 990, 120, 70, "是否有实收差异？"))
    cells.append(rect_node("16", 520, 1000, 140, 50, "创建实收差异单", "#FFCCBC", "#BF360C"))
    cells.append(rect_node("17", 320, 1080, 160, 60, "订单已锁定\n生成应收账款"))
    cells.append(oval_node("18", 340, 1160, 120, 50, "完成", "#C8E6C9", "#2E7D32"))

    cells.append(edge("e1", "2", "3"))
    cells.append(edge("e2", "3", "4"))
    cells.append(edge("e3", "4", "5"))
    cells.append(edge("e4", "5", "6"))
    cells.append(edge("e5", "6", "7"))
    cells.append(edge("e6", "7", "8", "否"))
    cells.append(edge("e7", "8", "4"))
    cells.append(edge("e8", "7", "9", "是"))
    cells.append(edge("e9", "9", "10"))
    cells.append(edge("e10", "10", "11"))
    cells.append(edge("e11", "11", "12"))
    cells.append(edge("e12", "12", "13"))
    cells.append(edge("e13", "13", "14"))
    cells.append(edge("e14", "14", "15"))
    cells.append(edge("e15", "15", "16", "是"))
    cells.append(edge("e16", "16", "17"))
    cells.append(edge("e17", "15", "17", "否"))
    cells.append(edge("e18", "17", "18"))
    save("03_客户直采流程.drawio", "客户直采流程", cells)


# -----------------------------
# 4. 智能下单流程（小程序商家端）
# -----------------------------
def smart_order_flow():
    cells = []
    cells.append(oval_node("2", 340, 20, 120, 50, "开始", "#C8E6C9", "#2E7D32"))
    cells.append(rect_node("3", 320, 90, 160, 60, "商家输入关键词\n语音/文字"))
    cells.append(rect_node("4", 320, 170, 160, 60, "AI 语义解析\n联想/纠错/分词"))
    cells.append(rect_node("5", 320, 250, 160, 60, "召回采购历史\n+ 运营主推 + 同类推荐"))
    cells.append(rect_node("6", 320, 330, 160, 60, "智能排序\n按优先级/频次/库存"))
    cells.append(rect_node("7", 320, 410, 160, 60, "商家浏览结果\n选择 SKU 加购"))
    cells.append(rect_node("8", 320, 490, 160, 60, "进入购物车\n确认数量/规格"))
    cells.append(rect_node("9", 320, 570, 160, 60, "选择地址/批次\n提交订单"))
    cells.append(oval_node("10", 340, 650, 120, 50, "完成", "#C8E6C9", "#2E7D32"))

    for i in range(2, 10):
        cells.append(edge(f"e{i}", str(i), str(i + 1)))
    save("04_智能下单流程.drawio", "智能下单流程", cells)


# -----------------------------
# 5. 差异处理流程
# -----------------------------
def discrepancy_flow():
    cells = []
    cells.append(oval_node("2", 360, 20, 120, 50, "发现异常", "#FFCCBC", "#BF360C"))
    cells.append(diamond_node("3", 360, 90, 120, 70, "判定差异环节"))
    cells.append(rect_node("4", 120, 100, 140, 60, "仓库内发现\n拣货差异", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("5", 360, 190, 120, 60, "配送途中发现\n配送差异", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("6", 600, 100, 140, 60, "签收时发现\n实收差异", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("7", 320, 280, 200, 60, "创建差异单\n关联订单/商品/凭证"))
    cells.append(rect_node("8", 320, 360, 200, 60, "记录差异类型/数量\n少收/拒收/残次/原因"))
    cells.append(diamond_node("9", 360, 440, 120, 70, "责任方判定"))
    cells.append(rect_node("10", 320, 540, 200, 60, "处理决策\n补货/退款/扣款/报损/不计"))
    cells.append(diamond_node("11", 360, 630, 120, 70, "是否调整金额？"))
    cells.append(diamond_node("12", 620, 630, 120, 70, "订单已锁定？"))
    cells.append(rect_node("13", 620, 740, 160, 60, "财务授权更正\n审计日志记录", "#FFCCBC", "#BF360C"))
    cells.append(rect_node("14", 320, 740, 200, 60, "更新订单金额/\n应收账款/供应商应付", "#E1F5FE", "#01579B"))
    cells.append(rect_node("15", 320, 830, 200, 60, "差异单关闭\n归档审计日志"))
    cells.append(oval_node("16", 360, 920, 120, 50, "完成", "#C8E6C9", "#2E7D32"))

    cells.append(edge("e1", "2", "3"))
    cells.append(edge("e2", "3", "4", "拣货"))
    cells.append(edge("e3", "3", "5", "配送"))
    cells.append(edge("e4", "3", "6", "实收"))
    cells.append(edge("e5", "4", "7"))
    cells.append(edge("e6", "5", "7"))
    cells.append(edge("e7", "6", "7"))
    cells.append(edge("e8", "7", "8"))
    cells.append(edge("e9", "8", "9"))
    cells.append(edge("e10", "9", "10"))
    cells.append(edge("e11", "10", "11"))
    cells.append(edge("e12", "11", "14", "是"))
    cells.append(edge("e13", "11", "15", "否"))
    cells.append(edge("e14", "14", "12"))
    cells.append(edge("e15", "12", "13", "是"))
    cells.append(edge("e16", "13", "15"))
    cells.append(edge("e17", "12", "15", "否"))
    cells.append(edge("e18", "15", "16"))
    save("05_差异处理流程.drawio", "差异处理流程", cells)


# -----------------------------
# 6. 财务结算流程
# -----------------------------
def finance_flow():
    cells = []
    cells.append(oval_node("2", 340, 20, 120, 50, "开始", "#C8E6C9", "#2E7D32"))
    cells.append(rect_node("3", 320, 90, 160, 60, "订单完成/签收"))
    cells.append(rect_node("4", 320, 170, 160, 60, "生成应收账款"))
    cells.append(diamond_node("5", 340, 250, 120, 70, "是否存在差异？"))
    cells.append(rect_node("6", 520, 260, 140, 50, "差异金额调整", "#FFCCBC", "#BF360C"))
    cells.append(diamond_node("7", 340, 350, 120, 70, "客户结算方式"))
    cells.append(rect_node("8", 120, 360, 120, 50, "余额扣款", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("9", 320, 440, 120, 50, "账期结算", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("10", 520, 360, 120, 50, "现结支付", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("11", 320, 510, 160, 60, "客户应收结算完成"))
    cells.append(rect_node("12", 320, 590, 160, 60, "按周期汇总\n供应商应付"))
    cells.append(rect_node("13", 320, 670, 160, 60, "服务费扣除\n生成结算单"))
    cells.append(rect_node("14", 320, 750, 160, 60, "供应商结算完成"))
    cells.append(rect_node("15", 320, 830, 160, 60, "发票管理\n申请/开具/寄出"))
    cells.append(oval_node("16", 340, 910, 120, 50, "完成", "#C8E6C9", "#2E7D32"))

    cells.append(edge("e1", "2", "3"))
    cells.append(edge("e2", "3", "4"))
    cells.append(edge("e3", "4", "5"))
    cells.append(edge("e4", "5", "6", "是"))
    cells.append(edge("e5", "6", "7"))
    cells.append(edge("e6", "5", "7", "否"))
    cells.append(edge("e7", "7", "8", "余额"))
    cells.append(edge("e8", "7", "9", "账期"))
    cells.append(edge("e9", "7", "10", "现结"))
    cells.append(edge("e10", "8", "11"))
    cells.append(edge("e11", "9", "11"))
    cells.append(edge("e12", "10", "11"))
    cells.append(edge("e13", "11", "12"))
    cells.append(edge("e14", "12", "13"))
    cells.append(edge("e15", "13", "14"))
    cells.append(edge("e16", "14", "15"))
    cells.append(edge("e17", "15", "16"))
    save("06_财务结算流程.drawio", "财务结算流程", cells)


# -----------------------------
# 7. 库存管理流程
# -----------------------------
def inventory_flow():
    cells = []
    cells.append(oval_node("2", 340, 20, 120, 50, "开始", "#C8E6C9", "#2E7D32"))
    cells.append(diamond_node("3", 360, 90, 120, 70, "库存变动类型"))
    cells.append(rect_node("4", 120, 100, 140, 60, "采购入库", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("5", 360, 190, 120, 60, "拣货出库", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("6", 600, 100, 140, 60, "库存调整/报损/报溢", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("7", 320, 280, 160, 60, "更新实时库存\n总库存/锁定/可用"))
    cells.append(rect_node("8", 320, 360, 160, 60, "记录库存变动日志\n类型/数量/原因/操作人"))
    cells.append(diamond_node("9", 340, 440, 120, 70, "库存低于预警值？"))
    cells.append(rect_node("10", 520, 450, 140, 50, "触发库存预警\n通知运营", "#FFCCBC", "#BF360C"))
    cells.append(rect_node("11", 320, 540, 160, 60, "库存盘点/效期管理"))
    cells.append(oval_node("12", 340, 630, 120, 50, "完成", "#C8E6C9", "#2E7D32"))

    cells.append(edge("e1", "2", "3"))
    cells.append(edge("e2", "3", "4", "入库"))
    cells.append(edge("e3", "3", "5", "出库"))
    cells.append(edge("e4", "3", "6", "调整"))
    cells.append(edge("e5", "4", "7"))
    cells.append(edge("e6", "5", "7"))
    cells.append(edge("e7", "6", "7"))
    cells.append(edge("e8", "7", "8"))
    cells.append(edge("e9", "8", "9"))
    cells.append(edge("e10", "9", "10", "是"))
    cells.append(edge("e11", "10", "11"))
    cells.append(edge("e12", "9", "11", "否"))
    cells.append(edge("e13", "11", "12"))
    save("07_库存管理流程.drawio", "库存管理流程", cells)


# -----------------------------
# 8. 拣货管理流程
# -----------------------------
def picking_flow():
    cells = []
    cells.append(oval_node("2", 340, 20, 120, 50, "开始", "#C8E6C9", "#2E7D32"))
    cells.append(rect_node("3", 320, 90, 160, 60, "订单进入\n待拣货状态"))
    cells.append(rect_node("4", 320, 170, 160, 60, "按库区/品类\n聚合生成拣货任务"))
    cells.append(rect_node("5", 320, 250, 160, 60, "分配拣货员"))
    cells.append(rect_node("6", 320, 330, 160, 60, "拣货员执行拣货\n录入实际数量"))
    cells.append(diamond_node("7", 340, 410, 120, 70, "是否称重改价？"))
    cells.append(rect_node("8", 520, 420, 140, 50, "称重录入\n计算实际金额"))
    cells.append(diamond_node("9", 340, 510, 120, 70, "差异是否超 20%？"))
    cells.append(rect_node("10", 520, 520, 140, 50, "标记待运营审核", "#FFCCBC", "#BF360C"))
    cells.append(diamond_node("11", 340, 600, 120, 70, "是否存在差异？"))
    cells.append(rect_node("12", 520, 610, 140, 50, "创建拣货差异单", "#FFCCBC", "#BF360C"))
    cells.append(rect_node("13", 320, 690, 160, 60, "完成拣货\n更新库存/订单状态"))
    cells.append(oval_node("14", 340, 770, 120, 50, "完成", "#C8E6C9", "#2E7D32"))

    cells.append(edge("e1", "2", "3"))
    cells.append(edge("e2", "3", "4"))
    cells.append(edge("e3", "4", "5"))
    cells.append(edge("e4", "5", "6"))
    cells.append(edge("e5", "6", "7"))
    cells.append(edge("e6", "7", "8", "是"))
    cells.append(edge("e7", "8", "9"))
    cells.append(edge("e8", "7", "9", "否"))
    cells.append(edge("e9", "9", "10", "是"))
    cells.append(edge("e10", "10", "11"))
    cells.append(edge("e11", "9", "11", "否"))
    cells.append(edge("e12", "11", "12", "是"))
    cells.append(edge("e13", "12", "13"))
    cells.append(edge("e14", "11", "13", "否"))
    cells.append(edge("e15", "13", "14"))
    save("08_拣货管理流程.drawio", "拣货管理流程", cells)


# -----------------------------
# 9. 物流配送流程
# -----------------------------
def delivery_flow():
    cells = []
    cells.append(oval_node("2", 340, 20, 120, 50, "开始", "#C8E6C9", "#2E7D32"))
    cells.append(rect_node("3", 320, 90, 160, 60, "拣货完成订单\n进入待配送"))
    cells.append(rect_node("4", 320, 170, 160, 60, "按线路聚合\n生成配送任务"))
    cells.append(rect_node("5", 320, 250, 160, 60, "分配司机/车辆\n（冷链/非冷链）"))
    cells.append(rect_node("6", 320, 330, 160, 60, "司机接单\n装车出发"))
    cells.append(rect_node("7", 320, 410, 160, 60, "按配送顺序导航\nGPS 轨迹上报"))
    cells.append(rect_node("8", 320, 490, 160, 60, "到达商家\n确认送达"))
    cells.append(rect_node("9", 320, 570, 160, 60, "拍照签收/\n电子签名/温度记录"))
    cells.append(diamond_node("10", 340, 650, 120, 70, "是否有实收差异？"))
    cells.append(rect_node("11", 520, 660, 140, 50, "创建实收差异单", "#FFCCBC", "#BF360C"))
    cells.append(rect_node("12", 320, 750, 160, 60, "任务完成\n订单已签收"))
    cells.append(oval_node("13", 340, 830, 120, 50, "完成", "#C8E6C9", "#2E7D32"))

    cells.append(edge("e1", "2", "3"))
    cells.append(edge("e2", "3", "4"))
    cells.append(edge("e3", "4", "5"))
    cells.append(edge("e4", "5", "6"))
    cells.append(edge("e5", "6", "7"))
    cells.append(edge("e6", "7", "8"))
    cells.append(edge("e7", "8", "9"))
    cells.append(edge("e8", "9", "10"))
    cells.append(edge("e9", "10", "11", "是"))
    cells.append(edge("e10", "11", "12"))
    cells.append(edge("e11", "10", "12", "否"))
    cells.append(edge("e12", "12", "13"))
    save("09_物流配送流程.drawio", "物流配送流程", cells)


# -----------------------------
# 10. 微信小程序商家端流程
# -----------------------------
def merchant_app_flow():
    cells = []
    cells.append(oval_node("2", 340, 20, 120, 50, "打开小程序", "#C8E6C9", "#2E7D32"))
    cells.append(rect_node("3", 320, 90, 160, 60, "微信登录\nOpenID 绑定"))
    cells.append(rect_node("4", 320, 170, 160, 60, "首页搜索/关键词\nAI 联想推荐"))
    cells.append(diamond_node("5", 340, 250, 120, 70, "选择下单方式？"))
    cells.append(rect_node("6", 120, 260, 140, 50, "智能搜索推荐", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("7", 340, 340, 120, 50, "常购清单", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("8", 560, 260, 140, 50, "收藏商品", "#FFF9C4", "#F57F17"))
    cells.append(rect_node("9", 320, 420, 160, 60, "商品详情\n选择规格加购"))
    cells.append(rect_node("10", 320, 500, 160, 60, "购物车管理\n修改数量/删除"))
    cells.append(rect_node("11", 320, 580, 160, 60, "订单确认\n选择地址/批次"))
    cells.append(rect_node("12", 320, 660, 160, 60, "提交订单"))
    cells.append(rect_node("13", 320, 740, 160, 60, "订单列表/详情\n查看配送进度"))
    cells.append(rect_node("14", 320, 820, 160, 60, "签收确认\n标记实收差异"))
    cells.append(oval_node("15", 340, 900, 120, 50, "完成", "#C8E6C9", "#2E7D32"))

    cells.append(edge("e1", "2", "3"))
    cells.append(edge("e2", "3", "4"))
    cells.append(edge("e3", "4", "5"))
    cells.append(edge("e4", "5", "6", "搜索"))
    cells.append(edge("e5", "5", "7", "常购"))
    cells.append(edge("e6", "5", "8", "收藏"))
    cells.append(edge("e7", "6", "9"))
    cells.append(edge("e8", "7", "9"))
    cells.append(edge("e9", "8", "9"))
    cells.append(edge("e10", "9", "10"))
    cells.append(edge("e11", "10", "11"))
    cells.append(edge("e12", "11", "12"))
    cells.append(edge("e13", "12", "13"))
    cells.append(edge("e14", "13", "14"))
    cells.append(edge("e15", "14", "15"))
    save("10_微信小程序商家端流程.drawio", "微信小程序商家端流程", cells)


# -----------------------------
# 11. 微信小程序司机端流程
# -----------------------------
def driver_app_flow():
    cells = []
    cells.append(oval_node("2", 340, 20, 120, 50, "打开小程序", "#C8E6C9", "#2E7D32"))
    cells.append(rect_node("3", 320, 90, 160, 60, "司机登录\n手机号+验证码"))
    cells.append(rect_node("4", 320, 170, 160, 60, "查看今日配送任务\n按批次/线路"))
    cells.append(rect_node("5", 320, 250, 160, 60, "查看任务详情\n订单/商家/地址"))
    cells.append(rect_node("6", 320, 330, 160, 60, "点击导航\n调用地图 SDK"))
    cells.append(rect_node("7", 320, 410, 160, 60, "GPS 轨迹上报\n实时位置"))
    cells.append(rect_node("8", 320, 490, 160, 60, "到达商家\n确认送达"))
    cells.append(rect_node("9", 320, 570, 160, 60, "拍照存证/\n电子签名/温度记录"))
    cells.append(diamond_node("10", 340, 650, 120, 70, "是否有实收差异？"))
    cells.append(rect_node("11", 520, 660, 140, 50, "标记实收差异", "#FFCCBC", "#BF360C"))
    cells.append(rect_node("12", 320, 750, 160, 60, "提交签收\n更新任务状态"))
    cells.append(rect_node("13", 320, 830, 160, 60, "历史任务查看"))
    cells.append(oval_node("14", 340, 910, 120, 50, "完成", "#C8E6C9", "#2E7D32"))

    cells.append(edge("e1", "2", "3"))
    cells.append(edge("e2", "3", "4"))
    cells.append(edge("e3", "4", "5"))
    cells.append(edge("e4", "5", "6"))
    cells.append(edge("e5", "6", "7"))
    cells.append(edge("e6", "7", "8"))
    cells.append(edge("e7", "8", "9"))
    cells.append(edge("e8", "9", "10"))
    cells.append(edge("e9", "10", "11", "是"))
    cells.append(edge("e10", "11", "12"))
    cells.append(edge("e11", "10", "12", "否"))
    cells.append(edge("e12", "12", "13"))
    cells.append(edge("e13", "13", "14"))
    save("11_微信小程序司机端流程.drawio", "微信小程序司机端流程", cells)


# -----------------------------
# 12. 权限/数据隔离流程（RBAC）
# -----------------------------
def rbac_flow():
    cells = []
    cells.append(oval_node("2", 340, 20, 120, 50, "用户登录", "#C8E6C9", "#2E7D32"))
    cells.append(rect_node("3", 320, 90, 160, 60, "验证账号密码\n发放 Sanctum Token"))
    cells.append(rect_node("4", 320, 170, 160, 60, "查询用户角色\n及角色权限"))
    cells.append(rect_node("5", 320, 250, 160, 60, "动态渲染\n菜单与按钮"))
    cells.append(diamond_node("6", 340, 330, 120, 70, "请求 API？"))
    cells.append(diamond_node("7", 340, 420, 120, 70, "是否有权限？"))
    cells.append(rect_node("8", 520, 430, 140, 50, "返回 403\n无权访问", "#FFCCBC", "#BF360C"))
    cells.append(diamond_node("9", 340, 510, 120, 70, "是否涉及\n商家数据？"))
    cells.append(rect_node("10", 520, 520, 140, 50, "注入 merchant_id\n数据隔离过滤", "#E1F5FE", "#01579B"))
    cells.append(rect_node("11", 320, 600, 160, 60, "执行业务逻辑"))
    cells.append(rect_node("12", 320, 680, 160, 60, "记录操作日志\n审计日志"))
    cells.append(oval_node("13", 340, 760, 120, 50, "返回结果", "#C8E6C9", "#2E7D32"))

    cells.append(edge("e1", "2", "3"))
    cells.append(edge("e2", "3", "4"))
    cells.append(edge("e3", "4", "5"))
    cells.append(edge("e4", "5", "6"))
    cells.append(edge("e5", "6", "7", "是"))
    cells.append(edge("e6", "7", "8", "否"))
    cells.append(edge("e7", "7", "9", "是"))
    cells.append(edge("e8", "9", "10", "是"))
    cells.append(edge("e9", "10", "11"))
    cells.append(edge("e10", "9", "11", "否"))
    cells.append(edge("e11", "11", "12"))
    cells.append(edge("e12", "12", "13"))
    save("12_权限与数据隔离流程.drawio", "权限与数据隔离流程", cells)


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    overall_architecture()
    procurement_flow()
    merchant_order_flow()
    smart_order_flow()
    discrepancy_flow()
    finance_flow()
    inventory_flow()
    picking_flow()
    delivery_flow()
    merchant_app_flow()
    driver_app_flow()
    rbac_flow()
    print("\n全部 drawio 流程图已生成到", OUT_DIR)
