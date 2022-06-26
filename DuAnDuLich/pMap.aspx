<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="pMap.aspx.cs" Inherits="DuAnDuLich.pMap" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Khu đất dự án du lịch chậm triển khai 2022</title>
    <link rel="stylesheet" href="https://js.arcgis.com/4.16/esri/css/main.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.3.0/font/bootstrap-icons.css"/>
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" ></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js"></script>
    <script src="https://js.arcgis.com/4.16/"></script>
    <style>
        html,
        body,
        #viewDiv {
            padding: 0;
            margin: 0;
            height: 100%;
            width: 100%;
        }

        #danhSach {
            display: none;
            opacity: 0.7;
            font-family: 'Arial';
            max-height: calc(80vh - 50px);
            overflow-y: auto;
        }

        #showDanhSach {
            display: block;
            border: none;
            font-size: 40px;
            color: #74b9ff;
            padding: 0px 3px;
            box-shadow: none;
            border-radius: 50%;
        }

        #danhSach::-webkit-scrollbar {
            width: 6px;
            background-color: #F5F5F5;
        }

        #danhSach::-webkit-scrollbar-thumb {
            background-color: #bdc3c7;
        }

        #danhSach:hover {
            opacity: 1;
        }

        #danhSach h1 {
            text-align: center;
            font-size: 1.2rem;
            text-transform: uppercase;
            margin-top: 10px;
        }

        #danhSach ul {
            list-style: none;
            margin: 0;
            padding: 0;
        }

        #danhSach li:before {
            content: attr(data-before);
        }

        #danhSach li {
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            cursor: pointer;
            padding: 0.2rem 0.5rem;
        }

            #danhSach li:hover {
                background-color: bisque;
            }


            #danhSach li:before {
                margin-right: 0.8rem;
                background: turquoise;
                border-radius: 50%;
                color: white;
                width: 2rem;
                height: 2rem;
                padding: 1rem;
                box-sizing: border-box;
                display: flex;
                justify-content: center;
                align-items: center;
            }

        .esri-widget {
            font-family: 'Roboto', sans-serif;
        }

        .esri-widget__table tr th {
            width: 30%;
            font-weight: bold;
        }

        .esri-widget__table tr td,
        .esri-widget__table tr th {
            font-size: 0.9rem;
            text-align: justify;
        }

        .esri-view-width-xlarge .esri-popup__main-container {
            width: 540px;
        }

        h1 {
            padding-left: 20px;
            padding-right: 20px;
        }
    </style>
     <%--<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>--%>
    <script type="text/javascript">
        //$(document).ready(() => {
        //    if ($('#lblMessage').text()) {
        //        $('#modalLogin').modal('show');
        //    }
        //});

        //function openModalUpload() {
        //    $('#lblMessage').empty();
        //    $('#modalLogin').modal('show');
        //}

        function login(event) {
            if (event.keyCode == 13) {
                document.getElementById("<%=lnkbtnLogin.ClientID%>").click();
            }
        }

        function closeModalLogin() {
            document.getElementById("btnCloseLogin").click();
            //event.preventDefault();
        }

        function openModalLogin()
        {
            document.getElementById("btOpenLogin").click();
            //event.preventDefault();
        }

        
        function LoadServiceMap(serviceDuAnDuLich) {
            var view;

            function createDanhSachDatDauGia(container, lstThuaDat) {
                var ul = document.createElement("ul");

                var titleThuaDat = document.createElement("h1");
                titleThuaDat.innerText = "Danh sách khu đất du lịch chậm triển khai";
                container.appendChild(titleThuaDat);

                lstThuaDat.sort((a, b) => {
                    return a.attributes['shthua'] - b.attributes['shthua'];
                });
                lstThuaDat.forEach((feature) => {
                    let name = feature.attributes['TENDUAN'];
                    let id = feature.attributes['shthua'];

                    var li = document.createElement("li");
                    li.setAttribute("data-before", id);
                    li.addEventListener('click', () => {
                        let extent = feature.geometry.extent;
                        //view.extent = extent;
                        view.goTo(extent);
                        toggleShow_DanhSach();
                    });

                    var text = document.createElement("span");
                    text.textContent = name;

                    li.appendChild(text);
                    ul.appendChild(li);
                });

                container.appendChild(ul);
                console.log(lstThuaDat);
            }

            function toggleShow_DanhSach() {
                let ds = document.getElementById("danhSach");
                if (window.getComputedStyle(ds).display === "none") {
                    ds.style.display = "block";
                } else {
                    ds.style.display = "none";
                }
            }

            require([
            "esri/Map",
            "esri/views/MapView",
            "esri/layers/FeatureLayer",
            "esri/layers/OpenStreetMapLayer",
            "esri/widgets/BasemapToggle"
            ], function (Map, MapView, FeatureLayer, OpenStreetMapLayer, BasemapToggle) {

                var map = new Map({
                    basemap: 'osm',
                });

                // var osmLayer = new OpenStreetMapLayer();
                // osmLayer.opacity = 0.8;

                var thuaDatLabels = {
                    labelPlacement: "above-center",
                    labelExpressionInfo: {
                        expression: "$feature.shthua"
                    },
                    symbol: {
                        type: "text",
                        color: "#FFFFFF",
                        haloColor: "#e74c3c",
                        haloSize: "2px",
                        font: {
                            size: "18px",
                            family: "Noto Sans",
                            style: "italic",
                            weight: "normal"
                        }
                    }
                }

                var contentShow = {
                    type: "fields",
                    fieldInfos: [{
                        fieldName: "TENDONVI",
                        label: "Tên đơn vị",
                    },
                    //{
                    //    fieldName: "gia_du_kien",
                    //    label: "Giá dự kiến (đồng)",
                    //    format: {
                    //        digitSeparator: true
                    //    }
                    //},.
                    {
                        fieldName: "LOAIDUAN",
                        label: "Loại dự án",
                    },
                    {
                        fieldName: "TENDUAN",
                        label: "Tên dự án",
                    },
                    {
                        fieldName: "DT_HA",
                        label: "Diện tích (ha)",
                    },
                    {
                        fieldName: "DIADIEM",
                        label: "Địa điểm",
                    },
                    {
                        fieldName: "KLTHANHTRA",
                        label: "Kết luận thanh tra",
                    },


                    ]
                };

                var thuaDatLayer = new FeatureLayer({
                    url: serviceDuAnDuLich,

                    opacity: 0.5,
                    labelingInfo: [thuaDatLabels],
                    popupTemplate: {
                        title: "Thông tin khu đất dự án du lịch chậm triển khai",
                        content: [contentShow],
                        overwriteActions: true,
                        expressionInfos: [{
                            name: "infoHoSo",
                            title: "Hồ sơ pháp lý",
                            expression: "$feature.HS_phaply"
                        },
                        {
                            name: "infoLienHe",
                            title: "Thông tin liên hệ",
                            expression: "$feature.Thongtin_lienhe"
                        },
                        ]
                    }
                });

                //map.add(osmLayer);
                map.add(thuaDatLayer);

                view = new MapView({
                    container: "viewDiv",
                    map: map,
                    center: [107.15821082685271, 10.507954291314137],
                    zoom: 11,
                    constraints: {
                        minScale: 2000000,
                    }
                });

                view.popup = {
                    dockEnabled: true,
                    dockOptions: {
                        // Disables the dock button from the popup
                        buttonEnabled: true,
                        // Ignore the default sizes that trigger responsive docking
                        breakpoint: false
                    }
                };

                var basemapToggle = new BasemapToggle({
                    view: view,
                    nextBasemap: "satellite"
                });


                var divThuaDat = document.createElement("div");
                divThuaDat.setAttribute("class", "esri-widget");
                divThuaDat.setAttribute("id", "danhSach");

                var buttonShow = document.createElement("button");
                buttonShow.setAttribute("class", "esri-widget");
                buttonShow.setAttribute("id", "showDanhSach");
                buttonShow.onclick = toggleShow_DanhSach;

                const icon = '<i class="fa fa-info-circle" aria-hidden="true"></i>'
                buttonShow.innerHTML = icon;

                view.ui.add(buttonShow, "top-right");
                view.ui.add(divThuaDat, "top-right");
                view.ui.add(basemapToggle, "bottom-right");

                view.when(() => {
                    // Fix lỗi không zoom extent
                    var query = thuaDatLayer.createQuery();
                    query.outSpatialReference = view.spatialReference;
                    thuaDatLayer.queryFeatures(query).then((result) => {
                        createDanhSachDatDauGia(divThuaDat, result.features);

                        // var idxFeature = 0;
                        // setInterval(() => {
                        //     let feature = result.features[idxFeature];
                        //     let extent = feature.geometry.extent;

                        //     view.goTo({
                        //         center: [107.15821082685271, 10.507954291314137],
                        //         zoom: 11,
                        //     }, {
                        //         duration: 1000
                        //     })

                        //     setTimeout(() => {
                        //         view.goTo(extent, {
                        //             duration: 1000
                        //         });
                        //     }, 1500);


                        //     view.popup.open({
                        //         features: result.features,
                        //         selectedFeatureIndex: idxFeature
                        //     });

                        //     idxFeature++;
                        //     if (idxFeature >= result.features.length)
                        //         idxFeature = 0;
                        // }, 15000);
                    });
                });
            });
        }

        function RegisterToken(url, strToken) {
            require([
                "esri/identity/IdentityManager"
            ], function (IdentityManager) {
                var token = {
                    'server': url,
                    'token': strToken
                };
                IdentityManager.registerToken(token);
            });
        };

       
    </script>
</head>

<body>
    <div id="viewDiv"></div>
    <button type="button" id="btOpenLogin" class="btn btn-info text-white" data-toggle="modal" data-target="#modalLogin" style="display: none" ></button>
    <form id="frmControlMap" runat="server">
        <%--<asp:ScriptManager runat="server"></asp:ScriptManager>--%>
        <%--Moldal Log in--%>
        <div class="modal fade" id="modalLogin" tabindex="-1" role="dialog" data-backdrop="static" data-keyboard="false">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content bg-gray" style="font-size: 18px">
                   <%-- <asp:UpdatePanel runat="server" ID="upLogin">
                        <ContentTemplate>--%>
                            <div class="modal-header">
                                <div class="col col-1 text-end">
                                </div>
                                <div class="col col-10 text-center">
                                    <h5 class="modal-title">ĐĂNG NHẬP TRANG DỰ ÁN DU LỊCH CHẬM TRIỂN KHAI</h5>
                                </div>
                                <div class="col col-1 text-end">
                                </div>

                            </div>
                            <div class="modal-body">
                                <div class="row justify-content-center">

                                    <div class="col-sm-10">
                                        <div class="input-group mb-3">
                                            <span class="input-group-text bi bi-person" id="basic-addon1"></span>
                                            <asp:TextBox runat="server" ID="txtUserName" CssClass="form-control pad-10" placeholder="Tên đăng nhập">
                                            </asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row justify-content-center">

                                    <div class="col-sm-10">
                                        <div class="input-group mb-3">
                                            <span class="input-group-text bi bi-key" id="basic-addon2"></span>
                                            <asp:TextBox runat="server" onkeydown="login(event);" ID="txtPassword" TextMode="Password" CssClass="form-control pad-10" placeholder="Mật khẩu">
                                            </asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <br />
                                <div class="row justify-content-center">
                                    <div class="col-sm-6 col-md-6">
                                        <asp:LinkButton runat="server" ID="lnkbtnLogin" OnClick="lnkbtnLogin_Click" CssClass="btn btn-success" Width="100%">
                                 <span class="bi bi-lock">&nbsp Đăng nhập</span>
                                        </asp:LinkButton>
                                        <button id="btnCloseLogin" type="button" class="btn-close" data-dismiss="modal" aria-label="Close" style="display: none"></button>
                                    </div>
                                </div>
                                <div class="row justify-content-center">
                                    <div class="col-sm-12 col-md-6 text-center">
                                        <asp:Label runat="server" ID="lblMessage" ForeColor="Red" EnableViewState="False">
                                        </asp:Label>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer"></div>

                        <%--</ContentTemplate>
                    </asp:UpdatePanel>--%>
                </div>
            </div>
        </div>
    </form>

</body>
</html>
