//
//  HistoricalViewController.swift
//  Seknova
//
//  Created by imac-3282 on 2025/12/18.
//

import UIKit
import DGCharts

class HistoricalViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var HistView: LineChartView!
    @IBOutlet weak var hrSec: UISegmentedControl!
    @IBOutlet weak var HistTime: UIImageView!
    @IBOutlet weak var Histlarge: UIImageView!
    
    // MARK: - Property
    private var selectedTimeRange: Int = 1 // 預設1小時
    private var currentEndDate: Date = Date() // 當前顯示的結束時間
    private var bloodGlucoseData: [BloodGlucoseEntry] = []
    private var lifeEvents: [LifeEvent] = []
    private var calibrationPoints: [CalibrationPoint] = []
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupChart()
        setupGestures()
        loadData()
    }
    
    // MARK: - UI Setting
    func setUI() {
        navigationItem.hidesBackButton = true
        title = "歷史紀錄"
        
        // 設定 SegmentedControl
        hrSec.removeAllSegments()
        hrSec.insertSegment(withTitle: "1 hr", at: 0, animated: false)
        hrSec.insertSegment(withTitle: "3 hr", at: 1, animated: false)
        hrSec.insertSegment(withTitle: "6 hr", at: 2, animated: false)
        hrSec.insertSegment(withTitle: "12 hr", at: 3, animated: false)
        hrSec.insertSegment(withTitle: "24 hr", at: 4, animated: false)
        hrSec.selectedSegmentIndex = 0
        hrSec.addTarget(self, action: #selector(timeRangeChanged(_:)), for: .valueChanged)
        
        // 設定按鈕手勢
        let timeGesture = UITapGestureRecognizer(target: self, action: #selector(moveToCurrentTime))
        HistTime.isUserInteractionEnabled = true
        HistTime.addGestureRecognizer(timeGesture)
        
        let largeGesture = UITapGestureRecognizer(target: self, action: #selector(showLargeView))
        Histlarge.isUserInteractionEnabled = true
        Histlarge.addGestureRecognizer(largeGesture)
    }
    
    private func setupChart() {
        guard let chartView = HistView else { return }
        
        // 基礎設定
        chartView.delegate = self
        chartView.backgroundColor = .white
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.highlightPerTapEnabled = true
        chartView.highlightPerDragEnabled = false
        
        // X 軸設定
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = true
        xAxis.gridColor = .lightGray.withAlphaComponent(0.5)
        xAxis.labelTextColor = .darkGray
        xAxis.granularity = 1
        xAxis.valueFormatter = DateValueFormatter()
        xAxis.avoidFirstLastClippingEnabled = true
        
        // Y 軸設定
        let leftAxis = chartView.leftAxis
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = .lightGray.withAlphaComponent(0.5)
        leftAxis.labelTextColor = .darkGray
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 400
        leftAxis.labelCount = 5
        leftAxis.granularity = 100
        
        chartView.rightAxis.enabled = false
        
        // 限制拖曳範圍（最多14天）
        chartView.dragDecelerationEnabled = true
        chartView.dragDecelerationFrictionCoef = 0.9
    }
    
    private func setupGestures() {
        // 圖表已經有內建的拖曳功能
    }
    
    // MARK: - Data Loading
    private func loadData() {
        // 生成示例血糖數據
        bloodGlucoseData = generateBloodGlucoseData()
        
        // 生成示例生活事件
        lifeEvents = generateLifeEvents()
        
        // 生成示例校正點
        calibrationPoints = generateCalibrationPoints()
        
        updateChartData()
    }
    
    private func generateBloodGlucoseData() -> [BloodGlucoseEntry] {
        var entries: [BloodGlucoseEntry] = []
        let now = Date()
        
        // 生成過去14天的數據，每15分鐘一個點
        for day in 0..<14 {
            for hour in 0..<24 {
                for minute in stride(from: 0, to: 60, by: 15) {
                    let timeInterval = TimeInterval(-day * 24 * 3600 - hour * 3600 - minute * 60)
                    let date = now.addingTimeInterval(timeInterval)
                    let value = Double.random(in: 80...250)
                    entries.append(BloodGlucoseEntry(date: date, value: value))
                }
            }
        }
        
        return entries.sorted { $0.date < $1.date }
    }
    
    private func generateLifeEvents() -> [LifeEvent] {
        var events: [LifeEvent] = []
        let now = Date()
        
        // 生成一些示例事件
        let eventTypes: [LifeEventType] = [.meal, .exercise, .medicine, .injection]
        
        for i in 0..<20 {
            let timeInterval = TimeInterval(-Double.random(in: 0...(14 * 24 * 3600)))
            let date = now.addingTimeInterval(timeInterval)
            let type = eventTypes.randomElement()!
            let note = "事件備註 \(i)"
            events.append(LifeEvent(date: date, type: type, note: note))
        }
        
        return events.sorted { $0.date < $1.date }
    }
    
    private func generateCalibrationPoints() -> [CalibrationPoint] {
        var points: [CalibrationPoint] = []
        let now = Date()
        
        // 每天2個校正點
        for day in 0..<14 {
            for time in [8, 20] { // 早上8點和晚上8點
                let timeInterval = TimeInterval(-day * 24 * 3600 - (24 - time) * 3600)
                let date = now.addingTimeInterval(timeInterval)
                let value = Double.random(in: 90...140)
                points.append(CalibrationPoint(date: date, value: value))
            }
        }
        
        return points.sorted { $0.date < $1.date }
    }
    
    private func updateChartData() {
        guard let chartView = HistView else { return }
        
        // 計算時間範圍
        let startDate = currentEndDate.addingTimeInterval(-TimeInterval(selectedTimeRange * 3600))
        
        // 過濾數據
        let filteredData = bloodGlucoseData.filter { entry in
            entry.date >= startDate && entry.date <= currentEndDate
        }
        
        // 轉換為 ChartDataEntry
        var entries: [ChartDataEntry] = []
        for entry in filteredData {
            let x = entry.date.timeIntervalSince1970
            entries.append(ChartDataEntry(x: x, y: entry.value))
        }
        
        // 創建數據集
        let dataSet = LineChartDataSet(entries: entries, label: "血糖值")
        dataSet.colors = [.systemRed]
        dataSet.lineWidth = 2.0
        dataSet.circleRadius = 4.0
        dataSet.circleColors = [.systemRed]
        dataSet.drawCircleHoleEnabled = true
        dataSet.circleHoleColor = .white
        dataSet.drawValuesEnabled = false
        dataSet.mode = .cubicBezier
        dataSet.highlightEnabled = true
        dataSet.highlightColor = .systemBlue
        dataSet.highlightLineWidth = 1.5
        
        // 添加校正點（用不同顏色標記）
        addCalibrationPointsToChart(startDate: startDate, endDate: currentEndDate)
        
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
        
        // 設定 X 軸範圍
        chartView.xAxis.axisMinimum = startDate.timeIntervalSince1970
        chartView.xAxis.axisMaximum = currentEndDate.timeIntervalSince1970
        
        // 添加生活事件圖標
        addLifeEventMarkers(startDate: startDate, endDate: currentEndDate)
        
        chartView.notifyDataSetChanged()
    }
    
    private func addCalibrationPointsToChart(startDate: Date, endDate: Date) {
        // 校正點會以特殊標記顯示
        let filteredCalibrations = calibrationPoints.filter { point in
            point.date >= startDate && point.date <= endDate
        }
        
        // 這裡可以用 ChartMarker 來顯示校正點
        // 暫時用標準點表示
    }
    
    private func addLifeEventMarkers(startDate: Date, endDate: Date) {
        guard let chartView = HistView else { return }
        
        // 過濾事件
        let filteredEvents = lifeEvents.filter { event in
            event.date >= startDate && event.date <= currentEndDate
        }
        
        // 在圖表上添加事件標記
        // 可以使用自定義 Marker 或在圖表底部添加圖標
        for event in filteredEvents {
            // TODO: 添加事件圖標到圖表
        }
    }
    
    // MARK: - IBAction
    @objc private func timeRangeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedTimeRange = 1
        case 1:
            selectedTimeRange = 3
        case 2:
            selectedTimeRange = 6
        case 3:
            selectedTimeRange = 12
        case 4:
            selectedTimeRange = 24
        default:
            selectedTimeRange = 1
        }
        
        updateChartData()
        print("時間範圍切換為: \(selectedTimeRange) 小時")
    }
    
    @objc private func moveToCurrentTime() {
        currentEndDate = Date()
        updateChartData()
        HistView.moveViewToX(currentEndDate.timeIntervalSince1970)
        print("移動到當前時間")
    }
    
    @objc private func showLargeView() {
        print("顯示放大趨勢圖")
        // TODO: 跳轉到橫向放大趨勢圖頁面
        let alert = UIAlertController(title: "放大趨勢圖", message: "此功能將顯示橫向放大的趨勢圖", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Function
    private func showBloodGlucoseDetail(entry: ChartDataEntry) {
        let date = Date(timeIntervalSince1970: entry.x)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        let timeString = dateFormatter.string(from: date)
        
        let alert = UIAlertController(
            title: "血糖值",
            message: "血糖值: \(Int(entry.y)) mg/dL\n記錄時間: \(timeString)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    private func showCalibrationDetail(point: CalibrationPoint) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        let timeString = dateFormatter.string(from: point.date)
        
        let alert = UIAlertController(
            title: "血糖校正",
            message: "校正值: \(Int(point.value)) mg/dL\n記錄時間: \(timeString)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    private func showLifeEventDetail(event: LifeEvent) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        let timeString = dateFormatter.string(from: event.date)
        
        let eventName = event.type.displayName
        
        let alert = UIAlertController(
            title: eventName,
            message: "記錄時間: \(timeString)\n註記: \(event.note)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - ChartViewDelegate
extension HistoricalViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // 點擊圖表上的點
        let date = Date(timeIntervalSince1970: entry.x)
        
        // 檢查是否是校正點
        if let calibration = calibrationPoints.first(where: { abs($0.date.timeIntervalSince(date)) < 60 }) {
            showCalibrationDetail(point: calibration)
            return
        }
        
        // 檢查是否是生活事件
        if let event = lifeEvents.first(where: { abs($0.date.timeIntervalSince(date)) < 300 }) {
            showLifeEventDetail(event: event)
            return
        }
        
        // 否則顯示血糖值
        showBloodGlucoseDetail(entry: entry)
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        // 處理圖表拖曳
        guard let chartView = HistView else { return }
        
        let lowestVisibleX = chartView.lowestVisibleX
        let highestVisibleX = chartView.highestVisibleX
        
        // 限制只能查看過去14天
        let fourteenDaysAgo = Date().addingTimeInterval(-14 * 24 * 3600)
        let minX = fourteenDaysAgo.timeIntervalSince1970
        
        if lowestVisibleX < minX {
            chartView.moveViewToX(minX)
        }
        
        // 更新當前結束時間
        currentEndDate = Date(timeIntervalSince1970: highestVisibleX)
    }
}

// MARK: - Data Models
struct BloodGlucoseEntry {
    let date: Date
    let value: Double
}

struct LifeEvent {
    let date: Date
    let type: LifeEventType
    let note: String
}

enum LifeEventType: String {
    case meal = "用餐"
    case exercise = "運動"
    case medicine = "服藥"
    case injection = "注射"
    
    var displayName: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .meal:
            return "fork.knife"
        case .exercise:
            return "figure.run"
        case .medicine:
            return "pills"
        case .injection:
            return "syringe"
        }
    }
}

struct CalibrationPoint {
    let date: Date
    let value: Double
}

// MARK: - Value Formatter
class DateValueFormatter: AxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "MM/dd HH:mm"
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}

