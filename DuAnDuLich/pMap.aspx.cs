using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace DuAnDuLich
{
    public partial class pMap : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string user = ConfigurationManager.AppSettings["AppUser"].ToString();
            string pass = ConfigurationManager.AppSettings["AppPassword"].ToString();
            if (txtUserName.Text != user || txtPassword.Text != pass)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "OpenModal", "openModalLogin();", true);
            }
        }
        private string GetTokenNen(string url, string username, string password)
        {
            string postString = $"username={username}&password={password}";
            string token = PostData(url, postString);//Gọi hàm post truy vấn dữ liệu json
            return token;
        }
        public static string PostData(string url, string postString)
        {
            string result = null;
            try
            {
                const string contentType = "application/x-www-form-urlencoded";
                ServicePointManager.Expect100Continue = false;

                var cookies = new CookieContainer();
                var webRequest = WebRequest.Create(url) as HttpWebRequest;
                webRequest.Method = "POST";
                webRequest.ContentType = contentType;
                webRequest.CookieContainer = cookies;
                webRequest.ContentLength = postString.Length;
                webRequest.UserAgent =
                    "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1";
                webRequest.Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";
                //webRequest.Referer = "";
                var requestWriter = new StreamWriter(webRequest.GetRequestStream());
                requestWriter.Write(postString);
                requestWriter.Close();
                var responseReader = new StreamReader(webRequest.GetResponse().GetResponseStream());
                result = responseReader.ReadToEnd();
                responseReader.Close();
                webRequest.GetResponse().Close();
            }
            catch (Exception ex)
            {
                return result = "Error";
            }
            return result;
        }

        protected void lnkbtnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrEmpty(txtUserName.Text) && string.IsNullOrEmpty(txtPassword.Text))
                {
                    lblMessage.Text = "Vui lòng nhập tên đăng nhập và mật khẩu";
                    return;
                }
                if (string.IsNullOrEmpty(txtUserName.Text))
                {
                    lblMessage.Text = "Vui lòng nhập tên đăng nhập";
                    return;
                }
                if (string.IsNullOrEmpty(txtPassword.Text))
                {
                    lblMessage.Text = "Vui lòng nhập mật khẩu";
                    return;
                }
                string user = ConfigurationManager.AppSettings["AppUser"].ToString();
                string pass = ConfigurationManager.AppSettings["AppPassword"].ToString();
                if(txtUserName.Text == user && txtPassword.Text == pass)
                {
                    string _userMap = ConfigurationManager.AppSettings["UserMap"].ToString();
                    string _passMap = ConfigurationManager.AppSettings["PasswordMap"].ToString();
                    string linkTokenMap = ConfigurationManager.AppSettings["LinkTokenMap"].ToString();
                    string serviceDuAnDuLich = ConfigurationManager.AppSettings["LinkServiceDADL"].ToString();
                    string linkServiceMap = ConfigurationManager.AppSettings["LinkServiceMap"].ToString();
                    string token = GetTokenNen(linkTokenMap, _userMap, _passMap);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "none",
                        $@"RegisterToken('{linkServiceMap}','{token}');
                    LoadServiceMap('{serviceDuAnDuLich}');", true);
                    Session.Add("user", txtUserName.Text);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseModal", "closeModalLogin();", true);
                }
                else
                {
                    lblMessage.Text = "Tên đăng nhập hoặc mật khẩu không đúng";
                    return;
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
            }
        }
    }
}